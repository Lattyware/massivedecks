import { InvalidActionError } from "../../errors/validation";
import * as User from "../../user";
import * as Validation from "../validation.validator";

/**
 * The details to register a new user for a lobby.
 */
export interface RegisterUser {
  /**
   * The name the user wishes to use.
   * @minLength 1
   * @maxLength 100
   */
  name: User.Name;
  /**
   * The lobby password, if there is one, this must be given and correct.
   * @minLength 1
   * @maxLength 100
   */
  password?: string;
}

const _validateRegisterUser = Validation.validate("RegisterUser");
export const validate = (action: object): RegisterUser => {
  try {
    return _validateRegisterUser(action);
  } catch (e) {
    throw new InvalidActionError(e.message);
  }
};
