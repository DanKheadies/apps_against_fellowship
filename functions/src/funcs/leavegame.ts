/* eslint-disable max-len */
import * as firebase from "../firebase/firebase";
import {error} from "../util/error";

/**
 * Leave Game - [Callable Function]
 *
 * This function let's a player leave a waiting room or an ongoing game
 * If the game is 'starting' then this request will be denied, if the game is completed only
 * the game reference is deleted, otherwise the player is set to inactive, removed from judging, and
 * any responses in the turn removed
 *
 * @param {any} data
 */
export async function handleLeaveGame(data: any) {
  const uid = data.data["uid"];
  const gameId = data.data["game_id"];

  if (!uid) {
    error("unauthenticated", "You must be authenticated to use this endpoint");
  }
  if (!gameId) {
    error("invalid-argument", "You must specify a valid game code or id");
  }

  const game = await firebase.games.getGame(gameId);
  if (game) {
    if (game.gameStatus === "starting") {
      error("unavailable", "You can't leave a game that is starting");
    }
    await firebase.firestore.runTransaction(async (transaction) => {
      if (game.gameStatus !== "completed") {
        firebase.games.leaveGame(transaction, uid, game);
        console.log("Player has been removed from an active game");
      }

      // Delete user game
      firebase.players.deleteUserGame(transaction, uid, gameId);
      console.log(`Player has left the game (${game.gameId})`);
    });

    return {
      game_id: gameId,
      success: true,
    };
  } else {
    error("not-found", `Couldn't find a game for the Code: ${gameId}`);
  }
}
