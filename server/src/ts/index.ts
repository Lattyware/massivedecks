import bodyParser from "body-parser";
import express, { NextFunction, Request, Response } from "express";
import "express-async-errors";
import expressWinston from "express-winston";
import ws from "express-ws";
import fs from "fs";
import helmet from "helmet";
import HttpStatus from "http-status-codes";
import JSON5 from "json5";
import sourceMapSupport from "source-map-support";
import { promisify } from "util";
import wu from "wu";
import * as checkAlive from "./action/initial/check-alive";
import * as createLobby from "./action/initial/create-lobby";
import * as registerUser from "./action/initial/register-user";
import * as serverConfig from "./config";
import { MassiveDecksError } from "./errors";
import { InvalidLobbyPasswordError } from "./errors/authentication";
import { UsernameAlreadyInUseError } from "./errors/registration";
import * as event from "./event";
import * as presenceChanged from "./events/lobby-event/presence-changed";
import { Player } from "./games/player";
import * as change from "./lobby/change";
import { GameCode } from "./lobby/game-code";
import * as logging from "./logging";
import * as serverState from "./server-state";
import * as timeout from "./timeout";
import * as userDisconnect from "./timeout/user-disconnect";
import * as user from "./user";
import * as token from "./user/token";

sourceMapSupport.install();

process.on("uncaughtException", function(error) {
  logging.logException("Uncaught exception: ", error);
  process.exit(1);
});

process.on("unhandledRejection", function(reason, promise) {
  logging.logger.error(`Unhandled rejection at ${promise}: ${reason}`);
  process.exit(1);
});

function getConfigFilePath(): string {
  const configPath = process.env["MD_CONFIG_PATH"];
  return configPath === undefined ? "config.json5" : configPath;
}

async function main(): Promise<void> {
  const config = serverConfig.parse(
    JSON5.parse(
      (await promisify(fs.readFile)(getConfigFilePath())).toString()
    ) as serverConfig.Unparsed
  );

  const { app } = ws(express());

  app.use(helmet());
  app.set("trust proxy", true);

  const environment = app.get("env");

  if (environment !== "development" && config.secret === "CHANGE ME") {
    throw new Error(
      "Secret not set - this should never be the case outside of " +
        "development. Please set a real random secret value in 'config.json5'."
    );
  }

  const state = await serverState.create(config);

  app.use(bodyParser.json());

  app.use(
    expressWinston.logger({
      winstonInstance: logging.logger
    })
  );

  app.get("/api/version", async (req, res) => res.json(config.version));

  app.get("/api/games", async (req, res) => {
    const result = [];
    for await (const summary of state.store.lobbySummaries()) {
      result.push(summary);
    }
    res.json(result);
  });

  app.post("/api/games", async (req, res) => {
    const { gameCode, token } = await state.store.newLobby(
      createLobby.validate(req.body),
      config.secret
    );
    res.append(
      "Location",
      `${req.protocol}://${req.hostname}/${config.basePath}api/games/${gameCode}`
    );
    res.status(HttpStatus.CREATED).json(token);
  });

  app.post("/api/alive", async (req, res) => {
    const result: { [key: string]: boolean } = {};
    for (const current of checkAlive.validate(req.body).tokens) {
      try {
        const claims = token.validate(
          current,
          await state.store.id(),
          state.config.secret
        );
        result[current] = await state.store.exists(claims.gc);
      } catch (error) {
        result[current] = false;
      }
    }
    res.json(result);
  });

  app.post("/api/games/:gameCode", async (req, res) => {
    const gameCode: GameCode = req.params.gameCode;

    const registration = registerUser.validate(req.body);
    const newUser = user.create(registration);
    const id = await change.applyAndReturn(state, gameCode, lobby => {
      if (lobby.config.password !== registration.password) {
        throw new InvalidLobbyPasswordError();
      }
      if (wu(lobby.users.values()).find(u => u.name === registration.name)) {
        throw new UsernameAlreadyInUseError(registration.name);
      }
      const id = lobby.nextUserId.toString();
      lobby.nextUserId += 1;
      lobby.users.set(id, newUser);
      const game = lobby.game;
      if (game !== undefined && newUser.role === "Player") {
        game.playerOrder.push(id);
        game.players.set(
          id,
          new Player(game.decks.responses.draw(game.rules.handSize))
        );
      }
      const unpause =
        game !== undefined
          ? game.paused
            ? game.startNewRound(state, lobby)
            : {}
          : {};
      return {
        change: {
          lobby,
          events: [
            event.targetAll(presenceChanged.joined(id, newUser)),
            ...(unpause.events !== undefined ? unpause.events : [])
          ],
          timeouts: [
            {
              timeout: userDisconnect.of(id),
              after: config.timeouts.disconnectionGracePeriod
            },
            ...(unpause.timeouts !== undefined ? unpause.timeouts : [])
          ]
        },
        returnValue: id
      };
    });
    const claims: token.Claims = {
      gc: gameCode,
      uid: id
    };
    res.json(token.create(claims, await state.store.id(), config.secret));
  });

  app.ws("/api/games/:gameCode", async (socket, req) => {
    const gameCode = req.params.gameCode;
    state.socketManager.add(state, gameCode, socket);
  });

  app.use((error: Error, req: Request, res: Response, next: NextFunction) => {
    if (res.headersSent) {
      next(error);
    }
    if (error instanceof MassiveDecksError) {
      logging.logger.warn("Bad request:", error.details());
      res.status(error.status).json(error.details());
    } else {
      next(error);
    }
  });

  app.use(
    expressWinston.errorLogger({
      winstonInstance: logging.logger,
      msg: "{{err.message}}"
    })
  );

  app.use((error: Error, req: Request, res: Response, next: NextFunction) => {
    if (res.headersSent) {
      next(error);
    }
    res
      .status(HttpStatus.INTERNAL_SERVER_ERROR)
      .json({ error: "InternalServerError" });
  });

  setInterval(async () => {
    try {
      const lobbies = await state.store.garbageCollect();
      if (lobbies > 0) {
        logging.logger.info(`Collected ${lobbies} ended/abandoned lobbies.`);
      }
    } catch (error) {
      logging.logException("Error garbage collecting:", error);
    }
  }, config.storage.garbageCollectionFrequency);

  setInterval(async () => {
    try {
      await timeout.handle(state);
    } catch (error) {
      logging.logException("Error running timeout:", error);
    }
  }, config.timeouts.timeoutCheckFrequency);

  state.tasks
    .loadFromStore(state)
    .catch(error => logging.logException("Error running store tasks:", error));

  app.listen(config.listenOn, async () => {
    logging.logger.info(`Listening on ${config.listenOn}.`);
    if (config.touchOnStart !== null) {
      const f = await promisify(fs.open)(config.touchOnStart, "w");
      await promisify(fs.close)(f);
    }
  });
}

main().catch(error => {
  logging.logException("Application exception:", error);
  process.exit(1);
});
