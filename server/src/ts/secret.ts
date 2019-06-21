import crypto from "crypto";

console.log(crypto.randomBytes(256 / 8).toString("hex"));
