/* eslint-disable max-len */
import {
  COLLECTION_GAMES,
  COLLECTION_PLAYERS,
  COLLECTION_USERS,
} from "../constants";
import {PromptCard, ResponseCard} from "../../models/cards";
import {firestore} from "../firebase";
import * as admin from "firebase-admin";
import FieldValue = admin.firestore.FieldValue;
import {Player} from "../../models/player";
import {UserGame} from "../../models/usergame";
import {User} from "../../models/user";

/**
 * Join a player to a given game id
 * @param {admin.firestore.Transaction} transaction the FB:FS transaction
 * @param {string} gameId the game to join
 * @param {Player} player the player to add
 */
export function joinGame(
  transaction: admin.firestore.Transaction,
  gameId: string,
  player: Player
) {
  const doc = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_PLAYERS)
    .doc(player.id);
  transaction.set(doc, player, {merge: true});
}

/**
 * Create a new UserGame object reference to the game on the player
 * @param {admin.firestore.Transaction} transaction the FB transaction to execute in
 * @param {string} uid the user's id
 * @param {string} gameId the games document id
 * @param {UserGame} userGame the document to write
 */
export function createUserGame(
  transaction: admin.firestore.Transaction,
  uid: string,
  gameId: string,
  userGame: UserGame
) {
  const doc = firestore
    .collection(COLLECTION_USERS)
    .doc(uid)
    .collection(COLLECTION_GAMES)
    .doc(gameId);
  transaction.set(doc, userGame, {merge: true});
}

/**
 * Delete a user game object from a user, effectively removing their access from it
 * @param {admin.firestore.Transaction} transaction
 * @param {string} uid
 * @param {string} gameId
 */
export function deleteUserGame(
  transaction: admin.firestore.Transaction,
  uid: string,
  gameId: string
) {
  const doc = firestore
    .collection(COLLECTION_USERS)
    .doc(uid)
    .collection(COLLECTION_GAMES)
    .doc(gameId);

  transaction.delete(doc);
}

/**
 * Set the hand for the provided user for a given game
 *
 * @param {string} gameId the id of the game in which the context of this action is being made
 * @param {string} playerId the id of the player to update
 * @param {ResponseCard[]} responseCards the list of {@link ResponseCard} to update as the player's hand
 */
export async function setHand(
  gameId: string,
  playerId: string,
  responseCards: ResponseCard[]
): Promise<void> {
  const playerDoc = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_PLAYERS)
    .doc(playerId);

  await playerDoc.update({
    hand: responseCards,
  });
}

/**
 * Set the hand for the provided user for a given game
 *
 * @param {admin.firestore.Transaction} transaction the transaction to apply this operation to
 * @param {string} gameId the id of the game in which the context of this action is being made
 * @param {string} playerId the id of the player to update
 * @param {ResponseCard[]} responseCards the list of {@link ResponseCard} to update as the player's hand
 * @return {admin.firestore.Transaction}
 */
export function setHandByTransaction(
  transaction: admin.firestore.Transaction,
  gameId: string,
  playerId: string,
  responseCards: ResponseCard[]
): admin.firestore.Transaction {
  const playerDoc = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_PLAYERS)
    .doc(playerId);

  return transaction.update(playerDoc, {
    hand: responseCards,
  });
}

/**
 * Re-deal hand for the provided user for a given game and remove a prize card as price
 *
 * @param {string} gameId the id of the game in which the context of this action is being made
 * @param {string} playerId the id of the player to update
 * @param {PromptCard} prize the prize to remove as cost
 * @param {ResponseCard[]} responseCards the list of {@link ResponseCard} to update as the player's hand
 */
export async function reDealHand(
  gameId: string,
  playerId: string,
  prize: PromptCard,
  responseCards: ResponseCard[]
): Promise<void> {
  const playerDoc = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_PLAYERS)
    .doc(playerId);

  await playerDoc.update({
    hand: responseCards,
    prizes: FieldValue.arrayRemove(prize),
  });
}

/**
 * Add a list of {@link ResponseCard}s to a given player's hand
 * @param {admin.firestore.Transaction} transaction
 * @param {string} gameId the id of the game this is context to
 * @param {string} playerId the id of the player to add to
 * @param {ResponseCard[]} responseCards the cards to add to their hand
 */
export function addToHand(
  transaction: admin.firestore.Transaction,
  gameId: string,
  playerId: string,
  responseCards: ResponseCard[]
) {
  const playerDoc = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_PLAYERS)
    .doc(playerId);

  transaction.update(playerDoc, {
    hand: FieldValue.arrayUnion(...responseCards),
  });
}

/**
 * Award a prompt card to a winning player
 * @param {string} gameId the game id
 * @param {string} playerId the player id
 * @param {PromptCard} promptCard the prize to award
 */
export async function awardPrompt(
  gameId: string,
  playerId: string,
  promptCard: PromptCard
): Promise<void> {
  const playerDoc = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_PLAYERS)
    .doc(playerId);

  await playerDoc.update({
    prizes: FieldValue.arrayUnion(promptCard),
  });
}

/**
 * Update all of a user's player objects in all of their games with their new name and/or avatarUrl
 * @param {string} userId the id of the user to update the player objs of
 * @param {User} updatedUser the new user obj to update with
 */
export async function updateAllPlayers(
  userId: string,
  updatedUser: User
): Promise<void> {
  const snapshot = await firestore
    .collectionGroup(COLLECTION_PLAYERS)
    .where("id", "==", userId)
    .get();

  if (!snapshot.empty) {
    await firestore.runTransaction(async (transaction) => {
      for (const doc of snapshot.docs) {
        transaction.update(doc.ref, {
          name: updatedUser.name,
          avatarUrl: updatedUser.avatarUrl,
        });
      }
    });
    console.log(
      `Updated all ${snapshot.docs.length} player objects for User(${userId})`
    );
  }
}
