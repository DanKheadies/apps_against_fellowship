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
  console.log("responses");
  console.log(responses);
  const indexedResponses: { [index: string]: string } =
    data.data["indexed_responses"];
  console.log("indexedResponses");
  console.log(indexedResponses);

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
    console.log("rawResponses");
    console.log(rawResponses);
    const newHand: ResponseCard[] =
      player.hand?.filter((c) => {
        return none(rawResponses, (cid) => c.cid === cid);
      }) || [];
    // TODO: something is happening here (newHand or submittedResponses) that
    // causes the order to get flipped / changed. Seems random, but there's
    // gotta be something..
    // I think it's submitted responses. In newHand, we filter out any cards from
    // our hand where their id matches the cid in the rawResponses map.
    // We do something similar below, but it might be based on the order of the
    // cards while in our hand, e.g. card #7 is played first then card #2 but
    // the end result here is #2 then #7 are collected, stored, and presented.
    // Nope, not that.. But something is happening in submittedRespones
    // Update: Yup, it's all based on the player hand and this filter.
    // If I submit card #3 1st and #8 2nd, it'll go thru my hand in reverse order,
    // i.e. card #1 is now card #9 (or whatever) and #9 is #1, and it grabs
    // whatever it finds first.
    // Ex:
    // I selected card #2 1st then #3 2nd. The raw/indexResponses shows them in the
    // correct order. However, player.hand shows my cards in reverse order, so
    // technicaly my card #2 is second to last in that list and #3 is 3rd to last.
    // So when I filter the hand to match any, it hits card #8, aka my #3, 1st.
    // Then it hits card #9, aka my #2, 2nd. So no submittedResponses has
    // #8 aka #3 as 1st and #9 aka #2 as 2nd.
    // If this was a Pick 3 and I sent #5 1st, #2 2nd, #8 3rd, then I would expect
    // the order to flip in player.hand. So 10 cards means #5 is now *6, #2 is now
    // *9, and #8 is now *2. Which means submittedResponses would show me
    // *2(#8 3rd) then *6 (#5 1st) then *9 (#2 2nd).
    // In other words, since nothing tracks the order at which they were submitted,
    // except for the original raw/indexResponses, this filter + any just drops
    // em in with no care. Also, flipping the player.hand order here doesn't quite
    // solve the issue either. I might still want to do that. For example (above),
    // *2 => #8, *6 => #5, *9 => #2, but it would still set as
    // #2 (2nd) then #5 (1st) then #8 (3rd).
    // I think the best thing to try to do would be to re-organize the
    // submittedResponses to match the order in raw/indexedResponses.
    // The main issue now is that I'm dealing with a List of ResponseCards for
    // submittedResponses. So I need to setup and if that
    // if (submittedResponses.length >= 2) THEN sort em
    // Update: I believe sortByIndexedMap should be fixing this, but it doesn't.
    // I'm going to replace the sorting with another to see if it fixes the issue.
    // If so, TODO to figure out what sortByIndex does and why it's going bump.
    console.log("player.hand");
    console.log(player.hand);
    let submittedResponses = player.hand?.filter((c) => {
      console.log(c.cid);
      return any(rawResponses, (cid) => c.cid === cid);
    });
    console.log("submittedResponses");
    console.log(submittedResponses);

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
        console.log(submittedResponses);
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
