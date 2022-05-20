import type { Action as ActionType } from "../action.js";
import type { CheckAlive as CheckAliveType } from "../action/initial/check-alive.js";
import type { CreateLobby as CreateLobbyType } from "../action/initial/create-lobby.js";
import type { RegisterUser as RegisterUserType } from "../action/initial/register-user.js";
import type { Public as PublicConfigType } from "../lobby/config.js";

export type Action = ActionType;
export type CreateLobby = CreateLobbyType;
export type RegisterUser = RegisterUserType;
export type CheckAlive = CheckAliveType;
export type PublicConfig = PublicConfigType;
