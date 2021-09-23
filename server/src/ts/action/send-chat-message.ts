import type { Action } from "../action.js";
import type * as Lobby from "../lobby.js";
import type * as Handler from "./handler.js";
import * as Actions from "./actions.js";
import * as Event from "../event.js";
import * as ReceiveChatMessage from "../events/lobby-event/receive-chat-message.js";

/**
 * A player sends a message in the chat.
 */
export interface SendChatMessage {
  action: "SendChatMessage";
  message: string;
}

class SendChatMessageActions extends Actions.Implementation<
  Action,
  SendChatMessage,
  "SendChatMessage",
  Lobby.Lobby
> {
  protected readonly name = "SendChatMessage";

  protected handle: Handler.Custom<SendChatMessage, Lobby.Lobby> = (
    auth,
    lobby,
    action,
  ) => {
    lobby.messages.push({
      content: action.message,
      author: auth.uid,
    });
    const allEvents = [
      Event.targetAll(
        ReceiveChatMessage.of({ content: action.message, author: auth.uid }),
      ),
    ];
    return {
      lobby,
      events: allEvents,
    };
  };
}

export const actions = new SendChatMessageActions();
