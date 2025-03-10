/* eslint-disable max-len */
// import { CallableContext } from "firebase-functions/lib/v1/providers/https";
import {error} from "../util/error";
import * as firebase from "../firebase/firebase.js";
import {all, any, none, reorderMaps} from "../util/array";
import {ResponseCard} from "../models/cards";
import {Player} from "../models/player";

/**
 * Submit Responses - [Callable Function]
 *
 * This function guards the user's response submissions to the current turn as well as notify the current judge
 * if all responses to a game have been submitted
 *
 * @param {any} data
 */
export async function handleSubmitResponses(data: any) {
  // const uid = context.auth?.uid;
  const uid = data.data["uid"];
  const gameId = data.data["game_id"];
  const responses: string[] = data.data["responses"];
  const indexedResponses: { [index: string]: string } =
    data.data["indexed_responses"];

  // Pre-conditions
  if (!uid) {
    error("unauthenticated", "You must be signed-in to perform this action");
  }
  if (!gameId) error("invalid-argument", "You must submit a valid game id");
  if ((!responses || responses.length === 0) && !indexedResponses) {
    error("invalid-argument", "You must submit valid responses");
  }

  // Fetch the game for the given document id
  await firebase.firestore.runTransaction(async (transaction) => {
    const game = await firebase.games.getGameByTransaction(transaction, gameId);
    if (!game) {
      error("not-found", "Unable to find the game for the provided id");
    }

    const players = await firebase.games.getPlayersByTransaction(
      transaction,
      gameId
    );
    if (!players || players.length === 0) {
      error("not-found", "Unable to find this player in this game");
    }
    const player = players.find((p) => p.id === uid);
    if (!player) error("not-found", "Unable to find this player in this game");

    // 1. Remove all responses from the player's hand and update that player's object
    const rawResponses = responses || Object.values(indexedResponses);

    const newHand: ResponseCard[] =
      player.hand?.filter((c) => {
        return none(rawResponses, (cid) => c.cid === cid);
      }) || [];

    let submittedResponses = player.hand?.filter((c) => {
      return any(rawResponses, (cid) => c.cid === cid);
    });

    if (submittedResponses) {
      // Update the user's hand in their game document
      firebase.players.setHandByTransaction(transaction, gameId, uid, newHand);

      // now we want to sort your 'submittedResponses' by the indexed map (if that was provided, i.e. Pick 2 /3)
      if (indexedResponses) {
        console.log("Sorting submitted responses by indexed order");
        // submittedResponses = sortByIndexedMap(
        //   submittedResponses,
        //   indexedResponses,
        //   (value) => value.cid
        // );
        submittedResponses = reorderMaps(submittedResponses, rawResponses);
      }

      // 2. If we have found valid submissions from that player's hand, then submit them to the game doc
      firebase.games.submitResponseCards(
        transaction,
        gameId,
        uid,
        submittedResponses
      );

      // now that we have "Submitted" a response, check if the turn would be ready for judging if the responses size
      // is close to 'full'
      const areResponsesAllIn =
        Object.keys(game.turn?.responses || []).length + 1 >
        (game.judgeRotation?.length || 0) - 1;
      if (areResponsesAllIn) {
        console.log("Responses have changed, and might be completed");

        // Check that all responses have been submitted
        const validPlayers = players.filter(
          (p) => p.id !== game.turn?.judgeId && !p.isInactive
        );
        const validateSubmission = (p: Player) => {
          return p.id === uid || game.turn?.responses?.[p.id] !== undefined;
        };
        if (all(validPlayers, validateSubmission)) {
          console.log("All players have submitted a response");
          // Send push to judge
          const judgePlayer = players.find((p) => p.id === game.turn?.judgeId);
          if (judgePlayer) {
            console.log(`Notifying the judge: ${judgePlayer.name}`);
            // TODO
            // await firebase.push.sendAllResponsesInMessage(game, judgePlayer);
          }
        }
      }
    }
  });

  return {
    game_id: gameId,
    success: true,
  };
}
