import { OutboundPort, RemoteControlCommand } from "../../elm/MassiveDecks";
import { channel, keepAliveChannel } from "./shared";

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

    context.addCustomMessageListener(keepAliveChannel, (customEvent: any) => {
      // Do nothing on the pong.
    });

    context.addEventListener(EventType.SENDER_CONNECTED, (event: any) => {
      const senderConnected = event as cast.framework.system.SenderConnectedEvent;
      setInterval(() => {
        context.sendCustomMessage(
          keepAliveChannel,
          senderConnected.senderId,
          "ping"
        );
      }, 30 * 1000);
    });

    context.start();
  }
}
