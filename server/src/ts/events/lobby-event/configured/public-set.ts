import * as configured from "../configured";

/**
 * The lobby password is (un)set.
 */
export interface PublicSet extends configured.Base {
  event: "PublicSet";
  public: boolean;
}

export const of = (version: string, isPublic: boolean): PublicSet => ({
  event: "PublicSet",
  version,
  public: isPublic
});
