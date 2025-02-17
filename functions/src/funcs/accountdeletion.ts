/* eslint-disable max-len */
import {UserRecord} from "firebase-functions/lib/v1/providers/auth";
// import {} from "firebase-functions/lib/v2/providers/";
import * as admin from "firebase-admin";
import {firestore} from "../firebase/firebase";
import {
  COLLECTION_DEVICES,
  COLLECTION_GAMES,
  COLLECTION_PLAYERS,
  COLLECTION_USERS,
} from "../firebase/constants";
import {UserGame} from "../models/usergame";
import {Game} from "../models/game";
import FieldValue = admin.firestore.FieldValue;

/**
 *
 * @param {UserRecord} user
 */
export async function handleAccountDeletion(user: UserRecord) {
  console.log(`Deleting User(${user.uid}, name=${user.displayName})`);

  const userDoc = firestore.collection(COLLECTION_USERS).doc(user.uid);

  const userGames = userDoc.collection(COLLECTION_GAMES);
  const userDevices = userDoc.collection(COLLECTION_DEVICES);

  // Delete all of the user's devices
  const userDevicesSnapshot = await userDevices.get();
  if (!userDevicesSnapshot.empty) {
    await firestore.runTransaction(async (transaction) => {
      for (const doc of userDevicesSnapshot.docs) {
        transaction.delete(doc.ref);
      }
    });
  }

  // Find and remove player from all games, then delete reference to them
  const userGamesSnapshot = await userGames.get();
  if (!userGamesSnapshot.empty) {
    await firestore.runTransaction(async (transaction) => {
      for (const doc of userGamesSnapshot.docs) {
        const userGame = doc.data() as UserGame;
        userGame.id = doc.id;
        await removePlayerFromGame(transaction, userGame, user.uid);
      }
      for (const doc of userGamesSnapshot.docs) {
        transaction.delete(doc.ref);
      }
    });
  }

  // Delete the user document
  await userDoc.delete();

  console.log(`Player(uid=${user.uid}) Deleted!`);
}

/**
 *
 * @param {admin.firestore.Transaction} transaction
 * @param {UserGame} userGame
 * @param {string} uid
 */
async function removePlayerFromGame(
  transaction: admin.firestore.Transaction,
  userGame: UserGame,
  uid: string
) {
  const gameDoc = firestore.collection(COLLECTION_GAMES).doc(userGame.id!);

  const gameSnapshot = await gameDoc.get();
  const game = gameSnapshot.data() as Game;

  if (game) {
    console.log(
      `Removing player from Game(gameId=${game.gameId}, id=${game.id})`
    );

    transaction.update(gameDoc, {
      judgeRotation: FieldValue.arrayRemove(uid),
    });

    const playerDoc = gameDoc.collection(COLLECTION_PLAYERS).doc(uid);
    transaction.update(playerDoc, {
      isInactive: true,
      avatarUrl: null,
      name: "[DELETED]",
    });
  }
}
