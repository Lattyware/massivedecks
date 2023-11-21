import type * as Chat from "../../lobby/chat.js";

/**
 * Indicates a new message has been sent to the lobby.
 */
export interface ReceiveChatMessage {
  event: "ReceiveChatMessage";
  message: Chat.Message;
}

export const of = (message: Chat.Message): ReceiveChatMessage => ({
  event: "ReceiveChatMessage",
  message,
});
