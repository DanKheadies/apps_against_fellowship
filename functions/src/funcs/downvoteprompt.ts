/* eslint-disable max-len */
import {
  Change,
  FirestoreEvent,
  QueryDocumentSnapshot,
} from "firebase-functions/v2/firestore";
import * as firestore from "../firebase/firebase";
import {Player, RANDO_CARDRISSIAN} from "../models/player";
import {getSpecial} from "../models/cards";
import {Turn} from "../models/turn";
import {Tally} from "../models/tally";
import {gameOver} from "../util/gameover";

const downVoteThreshold = 2 / 3;

/**
 * Downvotes - [Firestore onUpdate Trigger]
 *
 * Check if the update involves a change in the current (and same) turn's downvotes and if it does
 * check if the downvotes is >= 2/3rds of the player count. If this is the case then we will reset the current
 * turn and draw a new prompt card.
 *
 * 1. Check that turn doesn't change on this update
 * 2. Check that the number downvotes has changed
 * 3. Return all response cards that may have been submitted to the players
 * 4. Draw a new prompt card
 * 5. Reset the turn with new prompt, no downvotes, and no responses but keep the same judge
 *
 * @param {FirestoreEvent<Change<QueryDocumentSnapshot>>} event
 */
export async function handleDownVote(
  event: FirestoreEvent<
    Change<QueryDocumentSnapshot> | undefined,
    {
      gameId: string;
    }
  >
) {
  const gameId = event.params.gameId;

  const previousTally = event.data?.before.data() as Tally;
  const newTally = event.data?.after.data() as Tally;

  console.log(`Previous Game(${JSON.stringify(previousTally)})`);
  console.log(`New Game(${JSON.stringify(newTally)})`);

  const previousDownVotes = previousTally.votes;
  const newDownVotes = newTally.votes;
  console.log(
    `Comparing change in downvotes (previous=${previousDownVotes.length}, new=${newDownVotes.length})`
  );
  if (newDownVotes.length > previousDownVotes.length) {
    // Downvotes have changed pull the player list to check if > 2/3 of players have downvoted
    const players = await firestore.games.getPlayers(gameId);
    if (players) {
      const numPlayers = players.length;
      if (newDownVotes.length >= Math.floor(downVoteThreshold * numPlayers)) {
        // TODO: emit status change (loading) to drive user feedback
        // await firebase.games.updateState(gameId, "inProgress", players);
        // await firestore.games.update(gameId, {
        //   turn: turn,
        // });
        // Update: issue is that we want to update the GameState status to "downvoting"
        // But we only have access to the Game's status, e.g. inProgress, from here.
        // TBC

        console.log("Threshold Met, resetting turn");
        await resetTurn(gameId, players);
      }
    }
  }
}

/**
 *
 * @param {string} gameId
 * @param {Player[]} players
 */
async function resetTurn(gameId: string, players: Player[]): Promise<void> {
  const game = await firestore.games.getGame(gameId);
  if (game && game.turn) {
    // Store vetoed prompt card for posterity
    await firestore.games.storeVetoedPromptCard(gameId, game.turn.promptCard);

    // Return any responses to players
    await firestore.games.returnResponseCards(gameId, game);

    // Re-draw a new prompt card
    let newPromptCard;
    try {
      newPromptCard = await firestore.games.drawPromptCard(gameId);
    } catch (err) {
      await gameOver(game.gameId, gameId, "prompt", players);
    }

    const turn: Turn = {
      judgeId: game.turn.judgeId,
      promptCard: newPromptCard!,
      responses: {},
      winner: game.turn.winner,
    };

    if (game.turn.winner === undefined) {
      delete turn.winner;
    }

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
          await firestore.games.drawResponseCards(gameId, drawCount);
      } catch (err) {
        await gameOver(game.gameId, gameId, "response", players);
      }

      console.log("Rando Cardrissian has been dealt into the next turn");
    }

    // Reset the turn
    await firestore.games.update(gameId, {
      turn: turn,
    });

    // Clear out all the downvotes
    await firestore.games.clearDownvotes(gameId);

    // Send Push
    // TODO
    // await firestore.push.sendTurnResetMessage(game, players, turn);

    console.log(`The current turn has been reset for Game(${game.id})!`);
  }
}
