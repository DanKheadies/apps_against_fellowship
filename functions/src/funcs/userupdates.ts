/* eslint-disable max-len */
// import {
//   Change,
//   EventContext,
// } from "firebase-functions/lib/v1/cloud-functions";
// import { DocumentSnapshot } from "firebase-functions/lib/v1/providers/firestore";
import {
  Change,
  // DocumentSnapshot,
  FirestoreEvent,
  QueryDocumentSnapshot,
} from "firebase-functions/v2/firestore";
import {User} from "../models/user";
import * as firebase from "../firebase/firebase";

/**
 * User Updates - [Firestore onUpdate Trigger]
 *
 * Resource: `user/{userId}`
 *
 * When a user updates their name or avatar url we need to retro update all of
 * their Player objects on any games.
 *
 * @param {FirestoreEvent<Change<QueryDocumentSnapshot>>} event
 */
export async function handleUserUpdates(
  // change: Change<DocumentSnapshot>,
  // context: EventContext
  event: FirestoreEvent<
    Change<QueryDocumentSnapshot> | undefined,
    {
      userId: string;
    }
  >
) {
  const userId = event.params.userId;

  const previousUser = event.data?.before.data() as User;
  const newUser = event.data?.after.data() as User;

  console.log(`Previous User(${JSON.stringify(previousUser)})`);
  console.log(`Current User(${JSON.stringify(newUser)})`);
  // Update: avatarUrl didn't appear to come thru, i.e. it's gone in newUser.

  if (
    newUser.name !== previousUser.name ||
    newUser.avatarUrl !== previousUser.avatarUrl
  ) {
    console.log("User has changed their profile! Update all of their players");
    await firebase.players.updateAllPlayers(userId, newUser);
  }
}
