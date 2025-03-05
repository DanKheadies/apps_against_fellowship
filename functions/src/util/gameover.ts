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
  console.log("Game Over for: " + gameId);

  await firebase.games.updateStateWithData(
    gameId,
    {
      gameStatus: "gameOver",
      gameId: `${gameCode}-game-over`,
    },
    players
  );

  let fullReason;
  if (reason == "players") {
    fullReason =
      "Game Over. There are not enough players. Make more friends or something.";
  } else {
    fullReason =
      "Game Over. There are no more " +
      reason +
      " cards to draw. Select more sets or less prizes.";
  }

  error("resource-exhausted", fullReason);
}
