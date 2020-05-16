import jwt from "jsonwebtoken";
import {
  IncorrectIssuerError,
  InvalidAuthenticationError,
} from "../errors/authentication";
import { GameCode } from "../lobby/game-code";
import * as User from "../user";

/**
 * A token that contains the encoded claims of a user.
 */
export type Token = string;

/**
 * The information needed to authorize a user.
 * This is encoded into a JWT, signed so the information can be taken from the
 * user and verified without storing locally.
 */
export interface Claims {
  /**
   * The game code for the lobby this claim is valid in.
   */
  gc: GameCode;
  uid: User.Id;
}

/**
 * Make a signed token from some claims.
 * @param tokenClaims The claims.
 * @param issuer The store these claims are valid in.
 * @param secret The secret to sign the claims.
 */
export const create = (
  tokenClaims: Claims,
  issuer: string,
  secret: string
): Token =>
  jwt.sign(tokenClaims, secret, { algorithm: "HS256", issuer: issuer });

/**
 * Verify the given token and return the claims encoded in it, if valid.
 * Note this does *not* validate the game code in the claim.
 * @param token The token to validate.
 * @param issuer The store we are checking for.
 * @param secret The secret to verify the signature on the token.
 */
export function validate(token: Token, issuer: string, secret: string): Claims {
  try {
    return jwt.verify(token, secret, {
      algorithms: ["HS256"],
      issuer: issuer,
    }) as Claims;
  } catch (error) {
    if (error.hasOwnProperty("name") && error.name === "JsonWebTokenError") {
      if (error.message.startsWith("jwt issuer invalid.")) {
        throw new IncorrectIssuerError();
      } else if (error.message.startsWith("invalid signature")) {
        throw new InvalidAuthenticationError("invalid signature");
      }
    }
    throw error;
  }
}
