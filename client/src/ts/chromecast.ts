import {
  CastFlags,
  CastStatus,
  InboundPort,
  OutboundPort
} from "../elm/MassiveDecks";

const channel = "urn:x-cast:com.rereadgames.massivedecks";

declare const cast: any;

declare global {
  interface Window {
    __onGCastApiAvailable: any;
  }
}

let whenAvailable: (() => void)[] | null = [];

window["__onGCastApiAvailable"] = function(isAvailable: Boolean) {
  if (isAvailable) {
    cast.framework.CastContext.getInstance().setOptions({
      receiverApplicationId: "A6799922",
      autoJoinPolicy: chrome.cast.AutoJoinPolicy.ORIGIN_SCOPED
    });
    if (whenAvailable != null) {
      for (const callback of whenAvailable) {
        callback();
      }
      whenAvailable = null;
    } else {
      console.warn("Cast API initialized twice.");
    }
  }
};

abstract class WithCastApi {
  protected constructor() {
    if (whenAvailable == null) {
      this.onceCastApiAvailable();
    } else {
      whenAvailable.push(() => this.onceCastApiAvailable());
    }
  }

  abstract onceCastApiAvailable(): void;
}

/**
 * The client that lives on the MassiveDecks client.
 */
export class Client extends WithCastApi {
  readonly tryCast: InboundPort<CastFlags>;
  readonly status: OutboundPort<CastStatus>;
  flags: CastFlags | null;

  constructor(
    tryCast: InboundPort<CastFlags>,
    status: OutboundPort<CastStatus>
  ) {
    super();
    this.tryCast = tryCast;
    this.status = status;
    this.flags = null;
  }

  onceCastApiAvailable(): void {
    this.tryCast.subscribe((flags: CastFlags) => this.toggleCast(flags));
    const context = cast.framework.CastContext.getInstance();
    context.addEventListener(
      cast.framework.CastContextEventType.CAST_STATE_CHANGED,
      (event: cast.framework.CastStateEventData) =>
        this.onCastStateChanged(event)
    );
    context.addEventListener(
      cast.framework.CastContextEventType.SESSION_STATE_CHANGED,
      (event: cast.framework.SessionStateEventData) =>
        this.onSessionStateChanged(event)
    );
    this.status.send(context.getCastState());
  }

  toggleCast(flags: CastFlags): void {
    this.flags = flags;
    const context = cast.framework.CastContext.getInstance();
    if (context.getCastState() === cast.framework.CastState.CONNECTED) {
      context.endCurrentSession(true);
    } else {
      context.requestSession().then((e: chrome.cast.ErrorCode) => {
        if (e) {
          console.log(e);
        }
      });
    }
  }

  onCastStateChanged(event: cast.framework.CastStateEventData): void {
    let status: CastStatus;
    if (event.castState === cast.framework.CastState.NO_DEVICES_AVAILABLE) {
      status = { status: "NoDevicesAvailable" };
    } else if (event.castState === cast.framework.CastState.NOT_CONNECTED) {
      status = { status: "NotConnected" };
    } else if (event.castState === cast.framework.CastState.CONNECTING) {
      status = { status: "Connecting" };
    } else if (event.castState === cast.framework.CastState.CONNECTED) {
      status = { status: "Connected" };
      const session = cast.framework.CastContext.getInstance().getCurrentSession();
      if (session) {
        status.name = session.getCastDevice().friendlyName;
      }
    } else {
      throw new Error("Unknown cast state.");
    }
    this.status.send(status);
  }

  onSessionStateChanged(event: cast.framework.SessionStateEventData): void {
    if (
      !event.errorCode &&
      this.flags != null &&
      event.sessionState === cast.framework.SessionState.SESSION_STARTED
    ) {
      event.session
        .sendMessage(channel, JSON.stringify(this.flags))
        .catch((e: Error) => console.log(e));
    }
  }
}

/**
 * The server that lives on the chromecast.
 */
export class Server extends WithCastApi {
  readonly launch: (castFlags: CastFlags) => void;

  constructor(launch: (castFlags: CastFlags) => void) {
    super();
    this.launch = launch;
  }

  onceCastApiAvailable(): void {
    const context = cast.framework.CastReceiverContext.getInstance();

    context.addCustomMessageListener(channel, (customEvent: any) =>
      this.launch(customEvent.data)
    );

    context.start();
  }
}
