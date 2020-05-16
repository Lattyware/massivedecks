import {
  CloseCommand,
  ConnectionCommand,
  InboundPort,
  MessageCommand,
  OpenCommand,
  OutboundPort,
} from "../elm/MassiveDecks";

export function register(
  serverRecv: OutboundPort<string>,
  serverSend: InboundPort<ConnectionCommand>
) {
  new ServerConnection(serverRecv, serverSend);
}

function isOpen(command: ConnectionCommand): command is OpenCommand {
  return command.hasOwnProperty("gameCode");
}

function isMessage(command: ConnectionCommand): command is MessageCommand {
  return command.hasOwnProperty("message");
}

function isClose(command: CloseCommand): command is CloseCommand {
  return !isOpen(command) && !isMessage(command);
}

interface BaseUrl {
  protocol: string;
  host: string;
  path: string;
}

class ServerConnection {
  static readonly apiUrl = "api/games/";
  readonly base: string;
  readonly out: OutboundPort<string>;
  lobbyConnection: LobbyConnection | null;

  constructor(
    out: OutboundPort<string>,
    inbound: InboundPort<ConnectionCommand>
  ) {
    const baseElement = document.querySelector("base");
    const baseUrl =
      baseElement !== null
        ? ServerConnection.baseFromHtml(baseElement)
        : ServerConnection.baseFromLocation();
    const slash = baseUrl.path.endsWith("/") ? "" : "/";
    this.base =
      (baseUrl.protocol === "http:" ? "ws:" : "wss:") +
      ("//" + baseUrl.host + baseUrl.path + slash + ServerConnection.apiUrl);
    this.out = out;
    this.lobbyConnection = null;
    inbound.subscribe((command) => this.handleMessage(command));
  }

  static baseFromHtml(baseElement: HTMLBaseElement): BaseUrl {
    const url = new URL(baseElement.href);
    return {
      protocol: url.protocol,
      host: url.host,
      path: url.pathname,
    };
  }

  // Fallback - we should always have a base element so this should never get
  // hit. Note that we can't work out the base path from this.
  static baseFromLocation(): BaseUrl {
    const url = window.location;
    return {
      protocol: url.protocol,
      host: url.host,
      path: "",
    };
  }

  handleMessage(command: ConnectionCommand) {
    if (isOpen(command)) {
      if (this.lobbyConnection !== null) {
        this.lobbyConnection.close();
      }
      this.lobbyConnection = new LobbyConnection(
        this,
        this.base + command.gameCode,
        command.token
      );
    } else if (isMessage(command)) {
      if (this.lobbyConnection !== null) {
        this.lobbyConnection.send(command.message);
      }
    } else if (isClose(command)) {
      if (this.lobbyConnection !== null) {
        this.lobbyConnection.close();
      }
    }
  }
}

class LobbyConnection {
  static readonly oneSecond = 1000;
  static readonly oneMinute = LobbyConnection.oneSecond * 60;

  static readonly initialDelay = LobbyConnection.oneSecond / 2;
  static readonly maxDelay = LobbyConnection.oneMinute;

  socket: WebSocket;
  delay: number = LobbyConnection.initialDelay;
  closed: boolean = false;
  readonly token: string;

  constructor(parent: ServerConnection, url: string, token: string) {
    this.socket = this.open(parent, url);
    this.token = token;
  }

  open(parent: ServerConnection, url: string) {
    this.closed = false;
    const socket = new WebSocket(url);
    socket.addEventListener("message", (event) => {
      if (parent.lobbyConnection === this) {
        parent.out.send(event.data);
      }
    });
    socket.addEventListener("open", (_) => {
      this.delay = LobbyConnection.initialDelay;
      this.send(
        JSON.stringify({
          action: "Authenticate",
          token: this.token,
        })
      );
    });
    socket.addEventListener("close", (_) => {
      if (!this.closed) {
        setTimeout(() => {
          if (!this.closed) {
            if (parent.lobbyConnection === this) {
              this.delay = Math.min(LobbyConnection.maxDelay, this.delay * 2);
              this.socket = this.open(parent, url);
            }
          }
        }, this.delay);
      }
    });
    return socket;
  }

  send(message: string) {
    this.socket.send(message);
  }

  close() {
    this.closed = true;
    this.socket.close();
  }
}
