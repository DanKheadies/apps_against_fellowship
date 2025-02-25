/* eslint-disable max-len */
import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {onCall} from "firebase-functions/v2/https";
import {handleContactMessage} from "./funcs/contactmessage";
import {handleStartGame} from "./funcs/startgame";
import {handlePickWinner} from "./funcs/pickwinner";
import {handleDownVote} from "./funcs/downvoteprompt";
import {handleReDealHand} from "./funcs/redealhand";
// import { handleAccountDeletion } from "./funcs/accountdeletion";
import {handleJoinGame} from "./funcs/joingame";
import {handleSubmitResponses} from "./funcs/submitresponse";
import {handleUserUpdates} from "./funcs/userupdates";
import {handleLeaveGame} from "./funcs/leavegame";
import {handleKickPlayer} from "./funcs/kickplayer";
import {handleWave} from "./funcs/wave";

/**
 * Start Game - [Callable Function]
 *
 * This function serves to start a game that is in the 'waitingRoom' state by:
 *
 * 1. Populate card pool
 * 2. Generated first turn
 * 3. Deal cards to players
 * 4. Update GameStatus => 'inProgress'
 *
 * Request Params:
 *     'game_id': the Firestore Document Id of the game you want to start
 *
 * Response:
 * <p><code>
 *      {
 *          "game_id": "some_game_document_id",
 *          "success": true
 *      }
 * </code></p>
 */
// exports.startGame = onCall(handleStartGame);
export const startGame = onCall(async (data) => handleStartGame(data));

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
 */
export const pickWinner = onCall(async (data) => handlePickWinner(data));

/**
 * Re-Deal Hand - [Callable Function]
 *
 * This function will re-deal a user's hand in exchange for 1 prize card
 */
export const reDealHand = onCall(async (data) => handleReDealHand(data));

/**
 * Join Game - [Callable Function]
 *
 * This function is used to let player's join a game safely
 */
// exports.joinGame = onCall(handleJoinGame);
// export const joinGame = onCall(handleJoinGame);
export const joinGame = onCall(async (data) => handleJoinGame(data));

/**
 * Leave Game - [Callable Function]
 *
 * This function let's a player leave a waiting room or an ongoing game
 * If the game is 'starting' then this request will be denied, if the game is completed only
 * the game reference is deleted, otherwise the player is set to inactive, removed from judging, and
 * any responses in the turn removed
 */
export const leaveGame = onCall(async (data) => handleLeaveGame(data));

/**
 * Kick Player - [Callable Function]
 *
 * Kick a player from your game, only possible for game owner, and this will effectively ban them
 * from that game so they can't re-join
 */
export const kickPlayer = onCall(async (data) => handleKickPlayer(data));

/**
 * Submit Response - [Callable Function]
 *
 * This function will be used by players to be able to submit a response to an ongoing game
 */
export const submitResponses = onCall(async (data) =>
  handleSubmitResponses(data)
);

/**
 * Wave at a player - [Callable Function]
 *
 * This function will let players wave at other players
 *
 * Request Params:
 *     'game_id': the Firestore Document Id of the game you want to start
 *     'player_id': the id of the player you want to wave to
 */
export const wave = onCall(async (data) => handleWave(data));

/**
 * Downvotes - [Firestore onUpdate Trigger]
 *
 * Resource: `games/{gameId}/downvotes/{tally}`
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
 */
export const downvotePrompt = onDocumentUpdated(
  "games/{gameId}/downvotes/tally",
  (event) => handleDownVote(event)
);

/**
 * User Updates - [Firestore onUpdate Trigger]
 *
 * Resource: `user/{userId}`
 *
 * When a user updates their name or avatar url we need to retro update all of
 * their Player objects on any games.
 *
 * 1. Check if any part of the actual profile has changed
 * 2. Mass update user's Player objs
 */
// exports.updateUserProfile = functions.firestore
//   .document("users/{userId}")
//   .onUpdate(handleUserUpdates);
export const updateUserProfile = onDocumentUpdated("users/{userId}", (event) =>
  handleUserUpdates(event)
);

/**
 * Account Deletion - [Authentication Trigger]
 *
 * This function will listen to account deletions and delete all of their user data
 * stored in firebase
 */
// exports.accountDeletion = functions.auth.user().onDelete(handleAccountDeletion);
// UPDATE: This method for handling account deletion and user info removal has
// been deprecated with the change from v1 to v2. Instead, the Firebase project
// has a new "Delete User Data" extension that uses eventarc along with other
// methods to find and remove user info.

/**
 * Contact Message
 *
 * Send an "email" to Firebase document.
 * TODO: incorporate a true email service or send as a push notification topic.
 */
export const contactMessage = onCall(async (data) =>
  handleContactMessage(data)
);

/**
 * Test onCall function
 */
export const testCallFunction = onCall(async (data) => {
  console.log("test function is callable");
  console.log("data:");
  console.log(data.data);
  console.log(data.data["payload"]);
  console.log(data.data["data"]);
});
