/* eslint-disable max-len */
import {error} from "./error";
import * as firebase from "../firebase/firebase";
import {Player} from "../models/player";

/**
 * Update the game information to "gameOver" and throw error.
 * Currently being used when the game runs out of prompt & response cards.
 *
 * @param {string} gameCode // 5-digit code
 * @param {string} gameId // Firebase Id
 * @param {string} reason
 * @param {Player[]} players
 */
export async function gameOver(
  gameCode: string,
  gameId: string,
  reason: string,
  players: Player[]
) {
  console.log("game over for: " + gameId);
  await firebase.games.updateStateWithData(
    gameId,
    {
      gameStatus: "gameOver",
      gameId: `${gameCode}-game-over`,
    },
    players
  );
  console.log("now throwing error and bailing");
  error(
    "resource-exhausted",
    "Game Over. There are no more " +
      reason +
      " cards to draw. Select more sets or less prizes."
  );
}
