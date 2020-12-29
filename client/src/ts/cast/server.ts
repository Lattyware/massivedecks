import { OutboundPort, RemoteControlCommand } from "../../elm/MassiveDecks";
import { channel, keepAliveChannel } from "./shared";
import * as frameworkNs from "chromecast-caf-receiver/cast.framework";

export const register = (remoteControl: OutboundPort<RemoteControlCommand>) => {
  Server.start(remoteControl);
};

/**
 * The server that lives on the chromecast.
 */
class Server {
  static start(remoteControl: OutboundPort<RemoteControlCommand>) {
    // TypeScript gets confused about the sender and receiver frameworks overlapping, force it to the right one.
    const framework = cast.framework as unknown as typeof frameworkNs;

    const EventType = framework.system.EventType;

    const context = framework.CastReceiverContext.getInstance();

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
      const senderConnected = event as framework.system.SenderConnectedEvent;
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
