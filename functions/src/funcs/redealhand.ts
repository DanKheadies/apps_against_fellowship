/* eslint-disable max-len */
import { error } from "../util/error";
import * as firestore from "../firebase/firebase";
import { gameOver } from "../util/gameover";

/**
 * Re-Deal Hand - [Callable Function]
 *
 * This function will re-deal a user's hand in exchange for 1 prize card
 *
 * @param {any} data
 */
export async function handleReDealHand(data: any) {
  const uid = data.data["uid"];
  const gameId = data.data["game_id"];

  if (uid) {
    if (gameId) {
      const game = await firestore.games.getGame(gameId);
      if (game) {
        const player = await firestore.games.getPlayer(gameId, uid);
        if (player) {
          // Check if player has enough prizes to re-deal their hand
          if (player.prizes && player.prizes.length > 0) {
            console.log(
              `Player(${uid}) has enough prizes to re-deal their hand`
            );
            const prize = player.prizes.pop()!;
            let newHand;
            try {
              newHand = await firestore.games.drawResponseCards(gameId, 10);
            } catch (err) {
              const players = await firestore.games.getPlayers(gameId);
              if (!players || players.length === 0) {
                error("not-found", " No players found for this game");
              }
              await gameOver(game.gameId, gameId, "response", players);
            }

            await firestore.players.reDealHand(gameId, uid, prize, newHand!);
            console.log(
              `Successfully re-dealt hand for ${player.name} for the cost of ${prize.text}`
            );

            return {
              gameId: gameId,
              success: true,
            };
          } else {
            error(
              "failed-precondition",
              "You don't have enough prizes to re-deal your hand"
            );
          }
        } else {
          error(
            "not-found",
            "Unable to find you as a valid player for this game"
          );
        }
      } else {
        error("invalid-argument", "Please submit a valid game to re-deal");
      }
    } else {
      error("invalid-argument", "Please submit a valid game to re-deal");
    }
  } else {
    error("unauthenticated", "You must be signed-in to use this function");
  }
}
