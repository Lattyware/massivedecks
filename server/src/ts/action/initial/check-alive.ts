import { InvalidActionError } from "../../errors/validation.js";
import type { Token } from "../../user/token.js";
import * as Validation from "../validation.validator.js";

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
    const error = e as Error;
    throw new InvalidActionError(error.message);
  }
};
