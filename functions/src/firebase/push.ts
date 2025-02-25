/* eslint-disable max-len */
import * as admin from "firebase-admin";
import {Player} from "../models/player";
import {Turn} from "../models/turn";
import * as firebase from "./firebase";
import {COLLECTION_DEVICES, COLLECTION_USERS} from "./constants";
import {flatten} from "../util/flatmap";
import {Game} from "../models/game";
import Timestamp = admin.firestore.Timestamp;
import BatchResponse = admin.messaging.BatchResponse;
import MulticastMessage = admin.messaging.MulticastMessage;
import SendResponse = admin.messaging.SendResponse;

/**
 * Send a push notification to a user as a way to get them to re-engage with the game
 * @param {string} gameId the 5-digit id of the game you are waving from
 * @param {Player} from the player who is sending the wave
 * @param {Player} to the player to send the wave to
 * @param {string} message an optional message override for the push notification
 */
export async function sendWaveToPlayer(
  gameId: string,
  from: Player,
  to: Player,
  message?: string
) {
  const tokens = await getPlayerPushTokens([to]);
  await sendMulticastMessage({
    tokens: tokens,
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      gameId: gameId,
    },
    notification: {
      title: `${from.name} waves at you!`,
      body:
        message ||
        `${from.name} wants you to re-engage with the game. Maybe quit being a slacker.`,
    },
    android: {
      notification: {
        tag: "player-waved",
        ticker: "Player waved!",
        priority: "high",
      },
    },
  });
}

/**
 * Send a push notification to the game owner that a player has joined their game.
 *
 * @param {Game} game the game that was joined
 * @param {string} playerName the name of the player that joined
 */
export async function sendPlayerJoinedMessage(game: Game, playerName: string) {
  // TODO: convert to subscription topic (?)
  const tokens = await getPlayerPushTokens([
    {
      id: game.ownerId,
      isRandoCardrissian: false,
      name: "",
    },
  ]);
  await sendMulticastMessage({
    tokens: tokens,
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      gameId: game.id,
    },
    notification: {
      title: `Player Joined - ${game.gameId}`,
      body: `${playerName} has joined your game!`,
    },
    android: {
      notification: {
        tag: "player-joined",
        ticker: "Player joined!",
        priority: "high",
      },
    },
  });
}

/**
 * Notify the judge that all responses have been submitted and he must choose a winner
 * @param {Game} game the game in context
 * @param {Player} judge the current judge of the round
 */
export async function sendAllResponsesInMessage(game: Game, judge: Player) {
  const tokens = await getPlayerPushTokens([judge]);
  await sendMulticastMessage({
    tokens: tokens,
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      gameId: game.id,
    },
    notification: {
      title: `Time to judge - ${game.gameId}`,
      body: "All responses are in. Choose a winner!",
    },
    android: {
      notification: {
        tag: "all-responses",
        ticker: "Time to judge!",
        priority: "max",
      },
    },
  });
}

/**
 * Send push notifications for the start of a new game
 * @param {Game} game the game that started
 * @param {Player[]} players the players of that game
 * @param {Turn} firstTurn the indicating turn of the round to determine the judge to name
 */
export async function sendGameStartedMessage(
  game: Game,
  players: Player[],
  firstTurn: Turn
) {
  const tokens = await getPlayerPushTokens(players);
  const firstJudge = players.find((p) => p.id === firstTurn.judgeId);
  await sendMulticastMessage({
    tokens: tokens,
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      gameId: game.id,
    },
    notification: {
      title: `Game Started - ${game.gameId}`,
      body: `First judge is ${firstJudge?.name}`,
      imageUrl: firstJudge?.avatarUrl,
    },
    android: {
      notification: {
        tag: "game-started",
        ticker: "Game Started!",
        priority: "max",
      },
    },
  });
}

/**
 * Send a push notification to all players to let them know that the current turn prompt has been reset
 * and a new prompt is being chosen
 * @param {Game} game the game of context
 * @param {Player[]} players the players to notify
 * @param {Turn} newTurn the new turn generated
 */
export async function sendTurnResetMessage(
  game: Game,
  players: Player[],
  newTurn: Turn
) {
  const tokens = await getPlayerPushTokens(players);
  await sendMulticastMessage({
    tokens: tokens,
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      gameId: game.id,
    },
    notification: {
      title: `Game - ${game.gameId}`,
      body: `The prompt has been voted out, picking a new prompt! "${newTurn.promptCard.text}"`,
    },
    android: {
      notification: {
        tag: "turn-reset",
        ticker: "Turn reset!",
        priority: "high",
      },
    },
  });
}

/**
 * Send push notification to all players that the next round has started
 * - For player who is new Judge, tell them they are judge
 * - For player who won last round, tell them they won
 * - For everyone else, just state that round has started
 * @param {Game} game the game in context
 * @param {Turn} newTurn the next turn to be played
 * @param {Player[]} players the list of players to send the message to
 */
export async function sendNewRoundMessage(
  game: Game,
  newTurn: Turn,
  players: Player[]
) {
  const judgePushToken = await getPlayerPushTokens(
    players.filter((p) => p.id === newTurn.judgeId)
  );
  const winnerToken = await getPlayerPushTokens(
    players.filter((p) => p.id === newTurn.winner?.playerId)
  );
  const otherTokens = await getPlayerPushTokens(
    players.filter(
      (p) => p.id !== newTurn.judgeId && p.id !== newTurn.winner?.playerId
    )
  );

  if (judgePushToken.length > 0) {
    await sendNewJudgeMessage(game, judgePushToken);
  }
  if (winnerToken.length > 0) await sendWinnerMessage(game, winnerToken);
  if (otherTokens.length > 0) {
    await sendAllMessage(game, newTurn, game.round + 1, otherTokens);
  }
}

/**
 * Send a Game Over push notification to all players of this game
 * @param {Game} game the game in context
 * @param {Player[]} players the list of players to send message to
 * @param {Player} gameWinningPlayer the game winning player
 */
export async function sendGameOverMessage(
  game: Game,
  players: Player[],
  gameWinningPlayer: Player
) {
  const allTokens = await getPlayerPushTokens(players);
  await sendMulticastMessage({
    tokens: allTokens,
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      gameId: game.id,
    },
    notification: {
      title: `Game Over - ${game.gameId}`,
      body: `The winner was ${gameWinningPlayer.name}`,
      imageUrl:
        gameWinningPlayer.avatarUrl && gameWinningPlayer.avatarUrl.length > 0 ?
          gameWinningPlayer.avatarUrl :
          undefined,
    },
    android: {
      notification: {
        tag: "game-over",
        ticker: "Game Over!",
        priority: "high",
      },
    },
  });
}

/**
 *
 * @param {Game} game
 * @param {string[]} tokens
 */
async function sendNewJudgeMessage(game: Game, tokens: string[]) {
  await sendMulticastMessage({
    tokens: tokens,
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      gameId: game.id,
    },
    notification: {
      title: `Game - ${game.gameId}`,
      body: "You are now the judge!",
    },
    android: {
      notification: {
        tag: "new-judge",
        ticker: "You are now the judge!",
        priority: "high",
      },
    },
  });
  console.log("Sending New Judge Message!");
}

/**
 *
 * @param {Game} game
 * @param {string[]} tokens
 */
async function sendWinnerMessage(game: Game, tokens: string[]) {
  await sendMulticastMessage({
    tokens: tokens,
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      gameId: game.id,
    },
    notification: {
      title: `You won! - ${game.gameId}`,
      body: `"${game.turn?.promptCard?.text}"`,
    },
    android: {
      notification: {
        tag: "new-winner",
        ticker: "Winner!",
        priority: "high",
      },
    },
  });
  console.log("Sending Winner Message!");
}

/**
 *
 * @param {Game} game
 * @param {Turn} newTurn
 * @param {number} round
 * @param {string[]} tokens
 */
async function sendAllMessage(
  game: Game,
  newTurn: Turn,
  round: number,
  tokens: string[]
) {
  await sendMulticastMessage({
    tokens: tokens,
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      gameId: game.id,
    },
    notification: {
      title: `Next Round #${round} - ${game.gameId}`,
      body: `"${newTurn.promptCard.text}"`,
    },
    android: {
      notification: {
        tag: "new-round",
        ticker: "Next round started!",
        priority: "high",
      },
    },
  });
  console.log("Sending New Round Message!");
}

/**
 *
 * @param {MulticastMessage} message
 */
async function sendMulticastMessage(message: MulticastMessage) {
  const response = await firebase.messaging.sendEachForMulticast(message);
  await processBatchResponse(response);
}

/**
 *
 * @param {BatchResponse} response
 */
async function processBatchResponse(response: BatchResponse) {
  console.log(
    `Multicast Response(success=${response.successCount}, failure=${response.failureCount})`
  );
  if (response.failureCount > 0) {
    const failedResponses = response.responses.filter(
      (r: SendResponse) => !r.success
    );

    // I we have failed responses with the right failure code, reset push tokens
    for (const failedResponse of failedResponses) {
      if (
        failedResponse.error !== undefined &&
        failedResponse.messageId !== undefined
      ) {
        console.log(
          `Failed Response (code=${failedResponse.error.code}, msg=${failedResponse.error.message}, stack=${failedResponse.error.stack})`
        );
        switch (failedResponse.error.code) {
        case "messaging/invalid-registration-token":
        case "messaging/registration-token-not-registered":
          await invalidatePushToken(failedResponse.messageId);
          break;
        }
      }
    }
  }
}

/**
 *
 * @param {string} token
 */
async function invalidatePushToken(token: string) {
  // Find the token
  const snapshot = await firebase.firestore
    .collectionGroup(COLLECTION_DEVICES)
    .where("token", "==", token)
    .limit(1)
    .get();

  if (!snapshot.empty) {
    for (const doc of snapshot.docs) {
      await doc.ref.update({
        token: "",
        updatedAt: Timestamp.now(),
      });
    }
  }
}

/**
 *
 * @param {Player[]} players
 * @return {Promise<string[]>}
 */
async function getPlayerPushTokens(players: Player[]): Promise<string[]> {
  const devices = await Promise.all(
    players.map((value) => {
      return firebase.firestore
        .collection(COLLECTION_USERS)
        .doc(value.id)
        .collection(COLLECTION_DEVICES)
        .where("token", ">=", "")
        .get()
        .then((snap) => snap.docs.map((doc) => doc.data()["token"] as string));
    })
  );
  return flatten(devices);
}
