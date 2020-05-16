import bodyParser from "body-parser";
import express, { NextFunction, Request, Response } from "express";
import "express-async-errors";
import expressWinston from "express-winston";
import ws from "express-ws";
import { promises as fs } from "fs";
import helmet from "helmet";
import HttpStatus from "http-status-codes";
import JSON5 from "json5";
import sourceMapSupport from "source-map-support";
import wu from "wu";
import * as CheckAlive from "./action/initial/check-alive";
import * as CreateLobby from "./action/initial/create-lobby";
import * as RegisterUser from "./action/initial/register-user";
import * as ServerConfig from "./config";
import { MassiveDecksError } from "./errors";
import { InvalidLobbyPasswordError } from "./errors/authentication";
import { UsernameAlreadyInUseError } from "./errors/registration";
import * as Event from "./event";
import * as PresenceChanged from "./events/lobby-event/presence-changed";
import * as Player from "./games/player";
import * as Change from "./lobby/change";
import { GameCode } from "./lobby/game-code";
import * as Logging from "./logging";
import * as ServerState from "./server-state";
import * as Timeout from "./timeout";
import * as UserDisconnect from "./timeout/user-disconnect";
import * as User from "./user";
import * as Token from "./user/token";

sourceMapSupport.install();

process.on("uncaughtException", function (error) {
  Logging.logException("Uncaught exception: ", error);
});

process.on("unhandledRejection", function (reason, promise) {
  if (reason instanceof Error) {
    Logging.logException(`Unhandled rejection for ${promise}.`, reason);
  } else {
    Logging.logger.error(`Unhandled rejection at ${promise}: ${reason}`);
  }
});

function getConfigFilePath(): string {
  const configPath = process.env["MD_CONFIG_PATH"];
  return configPath === undefined ? "config.json5" : configPath;
}

async function main(): Promise<void> {
  const config = ServerConfig.parse(
    JSON5.parse(
      (await fs.readFile(getConfigFilePath())).toString()
    ) as ServerConfig.Unparsed
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

  const state = await ServerState.create(config);

  app.use(bodyParser.json());

  app.use(
    expressWinston.logger({
      winstonInstance: Logging.logger,
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
    const { gameCode, token, tasks } = await state.store.newLobby(
      CreateLobby.validate(req.body),
      config.secret,
      config.defaults
    );
    for (const task of tasks) {
      state.tasks.enqueue(state, task);
    }
    res.append(
      "Location",
      `${req.protocol}://${req.hostname}/${config.basePath}api/games/${gameCode}`
    );
    res.status(HttpStatus.CREATED).json(token);
  });

  app.post("/api/alive", async (req, res) => {
    const result: string[] = [];
    for (const current of CheckAlive.validate(req.body).tokens) {
      try {
        const claims = Token.validate(
          current,
          await state.store.id(),
          state.config.secret
        );
        if (await state.store.exists(claims.gc)) {
          result.push(current);
        }
      } catch (error) {
        // Ignore.
      }
    }
    res.json(result);
  });

  app.post("/api/games/:gameCode", async (req, res) => {
    const gameCode: GameCode = req.params.gameCode;

    const registration = RegisterUser.validate(req.body);
    const id = await Change.applyAndReturn(state, gameCode, (lobby) => {
      if (lobby.config.password !== registration.password) {
        throw new InvalidLobbyPasswordError();
      }
      const newUser = User.create(
        registration,
        lobby.config.audienceMode ? "Spectator" : "Player"
      );
      if (
        wu(Object.values(lobby.users)).find((u) => u.name === registration.name)
      ) {
        throw new UsernameAlreadyInUseError(registration.name);
      }
      const id = lobby.nextUserId.toString();
      lobby.nextUserId += 1;
      lobby.users[id] = newUser;
      const game = lobby.game;
      if (game !== undefined) {
        game.playerOrder.push(id);
        if (newUser.role === "Player") {
          game.players[id] = Player.initial(
            game.decks.responses.draw(game.rules.handSize)
          );
        }
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
            Event.targetAll(PresenceChanged.joined(id, newUser)),
            ...(unpause.events !== undefined ? unpause.events : []),
          ],
          timeouts: [
            {
              timeout: UserDisconnect.of(id),
              after: config.timeouts.disconnectionGracePeriod,
            },
            ...(unpause.timeouts !== undefined ? unpause.timeouts : []),
          ],
        },
        returnValue: id,
      };
    });
    const claims: Token.Claims = {
      gc: gameCode,
      uid: id,
    };
    res.json(Token.create(claims, await state.store.id(), config.secret));
  });

  app.ws("/api/games/:gameCode", async (socket, req) => {
    const gameCode = req.params.gameCode;
    state.socketManager.add(state, gameCode, socket);
  });

  app.get("/api/sources", async (req, res) => {
    res.json(state.sources.clientInfo());
  });

  app.use((error: Error, req: Request, res: Response, next: NextFunction) => {
    if (res.headersSent) {
      next(error);
    }
    if (error instanceof MassiveDecksError) {
      Logging.logger.warn("Bad request:", error.details());
      res.status(error.status).json(error.details());
    } else {
      next(error);
    }
  });

  app.use(
    expressWinston.errorLogger({
      winstonInstance: Logging.logger,
      msg: "{{err.message}}",
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
        Logging.logger.info(`Collected ${lobbies} ended/abandoned lobbies.`);
      }
    } catch (error) {
      Logging.logException("Error garbage collecting:", error);
    }
  }, config.storage.garbageCollectionFrequency);

  setInterval(async () => {
    try {
      await Timeout.handle(state);
    } catch (error) {
      Logging.logException("Error running timeout:", error);
    }
  }, config.timeouts.timeoutCheckFrequency);

  setInterval(async () => {
    try {
      await state.tasks.process(state);
    } catch (error) {
      Logging.logException("Error processing task queue:", error);
    }
  }, config.tasks.processTickFrequency);

  state.tasks
    .loadFromStore(state)
    .catch((error) =>
      Logging.logException("Error running store tasks:", error)
    );

  app.listen(config.listenOn, async () => {
    Logging.logger.info(`Listening on ${config.listenOn}.`);
    if (config.touchOnStart !== null) {
      const f = await fs.open(config.touchOnStart, "w");
      await f.close();
    }
  });
}

main().catch((error) => {
  Logging.logException("Application exception:", error);
  process.exit(1);
});
