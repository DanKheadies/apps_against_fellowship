/* eslint-disable max-len */
import {Change, EventContext} from "firebase-functions/lib/v1/cloud-functions";
import {DocumentSnapshot} from "firebase-functions/lib/v1/providers/firestore";
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
 * @param {Change<DocumentSnapshot>} change
 * @param {EventContext} context
 */
export async function handleUserUpdates(change: Change<DocumentSnapshot>, context: EventContext) {
  const userId = context.params.userId;

  const previousUser = change.before.data() as User;
  const newUser = change.after.data() as User;

  console.log(`Previous User(${JSON.stringify(previousUser)})`);
  console.log(`Current User(${JSON.stringify(newUser)})`);

  if (newUser.name !== previousUser.name || newUser.avatarUrl !== previousUser.avatarUrl) {
    console.log("User has changed their profile! Update all of their players");
    await firebase.players.updateAllPlayers(userId, newUser);
  }
}
