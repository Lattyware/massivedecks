import type { Action } from "../action.js";
import type * as Handler from "./handler.js";
import type * as Lobby from "../lobby.js";
import * as Actions from "./actions.js";

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
    console.log(lobby.messages);
    return {
      lobby,
    };
  };
}

export const actions = new SendChatMessageActions();
