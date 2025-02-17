/* eslint-disable max-len */
import {FunctionsErrorCode} from "firebase-functions/lib/v2/providers/https";
import * as functions from "firebase-functions";

/**
 * Do error stuff
 * @param {FunctionsErrorCode} code
 * @param {string} message
 */
export function error(code: FunctionsErrorCode, message: string): never {
  throw new functions.https.HttpsError(code, message);
}
