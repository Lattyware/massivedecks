import { InboundPort, OutboundPort } from "../elm/MassiveDecks";

/**
 * A notification message to show to the user.
 */
export interface Message {
  title: string;
  body: string;
}

/**
 * The state of the notification manager. This will only contain changed values.
 */
export interface State {
  permission?: "default" | "denied" | "granted" | "unsupported";
  visibility?: "visible" | "hidden" | "unsupported";
}

/**
 * A command to control the application.
 */
export type Control = "request-permissions";

/**
 * Any command from the main application.
 */
export type Command = Control | Message;

export function register(
  notificationState: OutboundPort<State>,
  notificationCommands: InboundPort<Command>
) {
  new NotificationManager(notificationState, notificationCommands);
}

/**
 * Checks if the given command is a message.
 * @param command the given command.
 */
const isMessage = (command: Command): command is Message =>
  command.hasOwnProperty("title");

/**
 * Throw an exception if we ever enter this function. Typescript guard.
 * @param value an impossible value.
 */
const assertUnreachable = (value: never): never => {
  throw new Error(`Unexpected value '${value}'.`);
};

/**
 * Manages showing notifications to the user through ports.
 */
export class NotificationManager {
  out: OutboundPort<State>;

  constructor(out: OutboundPort<State>, inbound: InboundPort<Command>) {
    inbound.subscribe(this.commandReceived.bind(this));
    this.out = out;

    this.out.send({
      permission:
        "Notification" in window ? Notification.permission : "unsupported",
      visibility:
        "visibilityState" in document
          ? document.visibilityState
          : "unsupported",
    });

    document.addEventListener(
      "visibilitychange",
      this.visibilityChange.bind(this),
      { passive: true }
    );
  }

  commandReceived(command: Command): void {
    if (isMessage(command)) {
      this.sendNotification(command);
    } else if (command === "request-permissions") {
      this.requestPermission();
    } else {
      assertUnreachable(command);
    }
  }

  requestPermission(): void {
    const callback = this.receivePermission.bind(this);
    try {
      Notification.requestPermission().then(callback);
    } catch (e) {
      // noinspection JSIgnoredPromiseFromCall
      Notification.requestPermission(callback);
    }
  }

  receivePermission(permission: NotificationPermission): void {
    this.out.send({
      permission,
    });
  }

  visibilityChange(): any {
    this.out.send({
      visibility: document.visibilityState === "visible" ? "visible" : "hidden",
    });
  }

  sendNotification(message: Message): void {
    const notification = new Notification(message.title, {
      body: message.body,
      tag: "game-progress",
    });
    setTimeout(notification.close.bind(notification), 4000);
  }
}
