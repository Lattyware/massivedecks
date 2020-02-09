import { InvalidActionError } from "../../errors/validation";
import { Token } from "../../user/token";
import * as Validation from "../validation.validator";

/**
 * Previously obtained tokens to check the validity of.
 */
export interface CheckAlive {
  tokens: Token[];
}

const _validateCheckAlive = Validation.validate("CheckAlive");
export const validate = (action: object): CheckAlive => {
  try {
    return _validateCheckAlive(action);
  } catch (e) {
    throw new InvalidActionError(e.message);
  }
};
