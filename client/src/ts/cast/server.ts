import { OutboundPort, RemoteControlCommand } from "../../elm/MassiveDecks";
import { channel } from "./shared";

export const register = (remoteControl: OutboundPort<RemoteControlCommand>) => {
  Server.start(remoteControl);
};

/**
 * The server that lives on the chromecast.
 */
class Server {
  static start(remoteControl: OutboundPort<RemoteControlCommand>) {
    const EventType = cast.framework.system.EventType;

    const context = cast.framework.CastReceiverContext.getInstance();

    context.addEventListener(EventType.ERROR, (event: any) => {
      console.error(event);
    });

    context.addCustomMessageListener(channel, (customEvent: any) =>
      remoteControl.send(customEvent.data)
    );

    context.start();
  }
}
