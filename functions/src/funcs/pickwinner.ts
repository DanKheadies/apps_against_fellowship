/* eslint-disable max-len */
// import { CallableContext } from "firebase-functions/lib/v1/providers/https";
import { error } from "../util/error";
import * as firebase from "../firebase/firebase";
import { Turn, TurnWinner } from "../models/turn";
import { getSpecial, PromptCard } from "../models/cards";
import { Player, RANDO_CARDRISSIAN } from "../models/player";
import { Game, nextJudge } from "../models/game";
import { drawN } from "../util/deal";
import { asyncMapValues } from "../util/map";
import { gameOver } from "../util/gameover";
import * as admin from "firebase-admin";
import FieldValue = admin.firestore.FieldValue;

/**
 * Pick Winner - [Callable Function]
 *
 * 1. Set winner on Turn object of the current game
 * 2. Award the prompt to the winning player
 * 3. Re-generate the Turn
 *    a. Draw new Prompt Card
 *    b. Clear responses
 *    c. Clear downvotes
 *    d. Draw Rando-Cardrissian, if present
 * 4. Draw new cards for all players
 *
 * TODO: Clean up this function to make it less monolith
 *
 * @param {any} data
 */
export async function handlePickWinner(data: any) {
  const uid = data.data["uid"];
  const gameId = data.data["game_id"];
  const winningPlayerId = data.data["player_id"];

  if (uid) {
    if (gameId) {
      // Load the game for this gameId and verify that it is in the correct state
      const game = await firebase.games.getGame(gameId);
      if (game) {
        game.id = gameId;
        const gameTurn = game.turn!;

        /*
         * Pre-Conditions
         */

        if (game.gameStatus !== "inProgress") {
          error(
            "failed-precondition",
            "This game is not in-progress, cannot pick a winner"
          );
        }

        if (gameTurn.judgeId !== uid) {
          error(
            "permission-denied",
            "Only the judge can pick a winner for the turn"
          );
        }

        const players = await firebase.games.getPlayers(gameId);
        if (!players || players.length === 0) {
          error("not-found", " No players found for this game");
        }

        // Prepare winner block
        const winningPlayer = players.find((p) => p.id === winningPlayerId);
        if (!winningPlayer) {
          error("invalid-argument", "No player found for that id");
        }

        const playerResponses = gameTurn.responses[winningPlayerId];
        if (!playerResponses) {
          error("invalid-argument", "Couldn't find players response");
        }

        /*
         * Create New Turn
         */

        const turnWinner: TurnWinner = {
          playerId: winningPlayer.id,
          playerName: winningPlayer.name,
          playerAvatarUrl: winningPlayer.avatarUrl,
          isRandoCardrissian: winningPlayer.isRandoCardrissian,
          promptCard: gameTurn.promptCard!,
          response: playerResponses,
          responses: gameTurn.responses,
        };

        // store this result for the data
        await firebase.games.storeTurn(game, turnWinner);

        // Pick next judge from order
        const newJudge = nextJudge(game, gameTurn.judgeId!);

        // Draw next prompt card
        let newPromptCard;
        try {
          newPromptCard = await firebase.games.drawPromptCard(gameId);
        } catch (err) {
          await gameOver(game.gameId, gameId, "prompt", players);
        }

        const turn: Turn = {
          judgeId: newJudge,
          responses: {},
          promptCard: newPromptCard!,
          winner: turnWinner,
        };

        // Go ahead and set Rando Cardrissian's response if he is a part of this game
        if (players.find((p) => p.isRandoCardrissian)) {
          let drawCount = 1;
          if (getSpecial(newPromptCard!.special) === "PICK 2") {
            drawCount = 2;
          } else if (getSpecial(newPromptCard!.special) === "DRAW 2, PICK 3") {
            drawCount = 3;
          }
          try {
            turn.responses[RANDO_CARDRISSIAN] =
              await firebase.games.drawResponseCards(gameId, drawCount);
          } catch (err) {
            await gameOver(game.gameId, gameId, "response", players);
          }
        }

        // Set the next turn and increment the round
        await firebase.games.update(gameId, {
          turn: turn,
          round: FieldValue.increment(1),
        });

        // Clear downvotes
        await firebase.games.clearDownvotes(gameId);

        // Award previous game's prompt to winning player
        await firebase.players.awardPrompt(
          gameId,
          winningPlayerId,
          game.turn!.promptCard
        );

        // Now Re-deal cards to the player based on the new prompt's special
        try {
          await dealNewCardsToPlayers(game, newPromptCard!, players);
        } catch (err) {
          await gameOver(game.gameId, gameId, "response", players);
        }

        // Check win condition, and set the game to completed
        const getPrizeLength = (player: Player) => {
          let prizeCount = player.prizes?.length || 0;
          if (player.id === winningPlayerId) {
            prizeCount += 1;
          }
          return prizeCount;
        };

        const gameWinningPlayer = players?.find(
          (p) => getPrizeLength(p) >= game.prizesToWin
        );
        if (gameWinningPlayer) {
          await firebase.games.updateStateWithData(
            gameId,
            {
              gameStatus: "completed",
              winner: gameWinningPlayer.id,
              gameId: `${game.gameId}-completed`,
            },
            players
          );

          // TODO
          // await firebase.push.sendGameOverMessage(
          //   game,
          //   players,
          //   gameWinningPlayer
          // );
        } else {
          // TODO
          // await firebase.push.sendNewRoundMessage(game, turn, players);
        }

        return {
          game_id: gameId,
          success: true,
        };
      } else {
        error("not-found", `Unable to find a game for ${gameId}`);
      }
    } else {
      error(
        "invalid-argument",
        'The function must be called with a valid "game_id".'
      );
    }
  } else {
    // Throw error
    error(
      "failed-precondition",
      "The function must be called while authenticated."
    );
  }
}

/**
 *
 * @param {Game} game
 * @param {PromptCard} newPrompt
 * @param {Player[]} players
 */
async function dealNewCardsToPlayers(
  game: Game,
  newPrompt: PromptCard,
  players: Player[]
) {
  // Now Re-deal cards to the player based on the new prompt's special
  let dealCount = 1;
  const previousPromptSpecial = getSpecial(game.turn?.promptCard!.special);
  if (previousPromptSpecial === "PICK 2") {
    dealCount = 2;
  }

  // if the next prompt card is a D2P3 then add an additional 2 cards to the deal
  if (getSpecial(newPrompt.special) === "DRAW 2, PICK 3") {
    dealCount += 2;
  }

  // Get response card pool
  const cardPool = await firebase.games.getResponseCardPool(game.id);
  const playerIndexes = new Map<string, string[]>();

  // Seed the player indexes with their cards
  players
    .filter((p) => !p.isRandoCardrissian && p.id !== game.turn?.judgeId)
    .forEach((p) => {
      playerIndexes.set(p.id, drawN(cardPool.cards, dealCount));
    });

  // Update the game seed with now draw cards removed
  try {
    await firebase.games.seedCardPool(game.id, [], cardPool.cards);
  } catch (err) {
    await gameOver(game.gameId, game.id, "response", players);
  }

  // Get the actual cards from the DB
  const playerCards = await asyncMapValues(playerIndexes, async (indexes) => {
    return await firebase.cards.getResponseCards(indexes);
  });

  await firebase.firestore.runTransaction(async (transaction) => {
    for (const [playerId, responseCards] of playerCards.entries()) {
      firebase.players.addToHand(transaction, game.id, playerId, responseCards);
      console.log(
        `New cards(count=${responseCards.length}) dealt to ${playerId}`
      );
    }
  });
}
