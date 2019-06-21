import { InvalidActionError } from "../../errors/validation";
import * as user from "../../user";
import * as validation from "../validation.validator";

/**
 * The details to register a new user for a lobby.
 */
export interface RegisterUser {
  /**
   * The name the user wishes to use.
   */
  name: user.Name;
  /**
   * The lobby password, if there is one, this must be given and correct.
   */
  password?: string;
}

const _validateRegisterUser = validation.validate("RegisterUser");
export const validate = (action: object): RegisterUser => {
  try {
    return _validateRegisterUser(action);
  } catch (e) {
    throw new InvalidActionError(e.message);
  }
};
