/* eslint-disable max-len */
// import {CallableContext} from "firebase-functions/lib/v1/providers/https";
import {error} from "../util/error";
import * as firebase from "../firebase/firebase.js";

/**
 * Wave at a player - [Callable Function]
 *
 * This function will let players wave at other players
 *
 * Request Params:
 *     'game_id': the Firestore Document Id of the game you want to start
 *     'player_id': the id of the player you want to wave to
 *     'message': Optional. The message to send in the push notification.
 *
 * @param {any} data
 */
export async function handleWave(data: any) {
  const uid = data.data["uid"];
  const gameId = data.data["game_id"];
  const playerId = data.data["player_id"];
  // const message = data.message || null;

  // Pre-conditions
  if (!uid) {
    error("unauthenticated", "You must be signed-in to perform this action");
  }
  if (!gameId) error("invalid-argument", "You must submit a valid game id");
  if (!playerId) error("invalid-argument", "You must submit a valid player id");

  // Verify that the player is part of the game
  const from = await firebase.games.getPlayer(gameId, uid);
  const to = await firebase.games.getPlayer(gameId, playerId);
  if (!from) {
    error("not-found", "Unable to find the player who is sending the wave");
  }
  if (!to) {
    error("not-found", "Unable to find the player for the provided game");
  }

  // Send push notification to this user's devices
  // TODO
  // await firebase.push.sendWaveToPlayer(gameId, from, to, message);

  console.log(`Wave was sent to Player(${to.id}) from Player(${uid})`);
}
