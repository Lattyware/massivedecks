import { Say, Voice } from "../../ts/speech";
import {
  State as NotificationState,
  Command as NotificationCommand
} from "../../ts/notification-manager";

type Token = string;

interface Settings {
  tokens: Token[];
  lastUsedName: string | null;
  recentDecks: string[];
  chosenLanguage: string | null;
}

interface Flags {
  settings: Settings;
  browserLanguages: string[];
}

interface CastFlags {
  token: Token;
}

interface CastStatus {
  status: string;
  name?: string;
}

interface OpenCommand {
  gameCode: string;
  token: string;
}

interface MessageCommand {
  message: string;
}

interface CloseCommand {}

type ConnectionCommand = OpenCommand | MessageCommand | CloseCommand;

export interface InboundPort<T> {
  subscribe(callback: (data: T) => void): void;
}

export interface OutboundPort<T> {
  send(data: T): void;
}

export namespace Elm {
  namespace MassiveDecks {
    export interface App {
      ports: {
        notificationState: OutboundPort<NotificationState>;
        notificationCommands: InboundPort<NotificationCommand>;
        speechCommands: InboundPort<Say>;
        speechVoices: OutboundPort<Array<Voice>>;
        storeSettings: InboundPort<Settings>;
        tryCast: InboundPort<CastFlags>;
        castStatus: OutboundPort<CastStatus>;
        serverRecv: OutboundPort<string>;
        serverSend: InboundPort<ConnectionCommand>;
        copyText: InboundPort<string>;
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: Flags;
    }): Elm.MassiveDecks.App;

    namespace Cast {
      export interface App {}
      export function init(options: {
        node?: HTMLElement | null;
        flags: CastFlags;
      }): Elm.MassiveDecks.App;
    }
  }
}
