/* eslint-disable max-len */
// import { CallableContext } from "firebase-functions/lib/common/providers/https";
import {error} from "../util/error";
import * as firebase from "../firebase/firebase";
import {nextJudge} from "../models/game";

/**
 * Kick Player - [Callable Function]
 *
 * Kick a player from your game, only possible for game owner, and this will effectively ban them
 * from that game so they can't re-join
 *
 * @param {any} data
 */
export async function handleKickPlayer(data: any) {
  // const uid = context.auth?.uid;
  const uid = data.uid;
  const gameId = data.game_id;
  const playerId = data.player_id;

  if (!uid) {
    error("unauthenticated", "You must be authenticated to use this endpoint");
  }
  if (!gameId) error("invalid-argument", "You must specify a valid game");
  if (!playerId) {
    error("invalid-argument", "You must specify the player you want to kick");
  }

  const game = await firebase.games.getGame(gameId);
  if (game) {
    // Verify that authenticated user is the owner
    if (game.ownerId === uid) {
      // Mark player as in-active
      await firebase.firestore.runTransaction(async (transaction) => {
        // If the user is the current judge, cycle the judges
        if (game.turn?.judgeId === playerId) {
          const newJudge = nextJudge(game, playerId);
          firebase.games.updateByTransaction(transaction, gameId, {
            "turn.judgeId": newJudge,
          });
          console.log(`New Judge(${newJudge}) Picked!`);
        }
        firebase.games.leaveGame(transaction, playerId, game);
        firebase.players.deleteUserGame(transaction, uid, gameId);
      });

      console.log(
        `Player(${playerId}) was kicked from the Game(${game.gameId})`
      );

      return {
        success: true,
        game_id: gameId,
      };
    } else {
      error("permission-denied", "Only the owner of a game can kick a player");
    }
  } else {
    error("not-found", `Couldn't find a game for the Code: ${gameId}`);
  }
}
