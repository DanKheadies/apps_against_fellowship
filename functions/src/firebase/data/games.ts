/* eslint-disable max-len */
import {
  COLLECTION_CARD_POOL,
  COLLECTION_DOWNVOTES,
  COLLECTION_GAMES,
  COLLECTION_PLAYERS,
  COLLECTION_TURNS,
  COLLECTION_USERS,
  COLLECTION_VETOED,
  DOCUMENT_PROMPTS,
  DOCUMENT_RESPONSES,
  DOCUMENT_TALLY,
} from "../constants";
import {Game, GameStatus} from "../../models/game";
import {Player, RANDO_CARDRISSIAN} from "../../models/player";
import {cards, firestore} from "../firebase";
import {PromptCard, ResponseCard} from "../../models/cards";
import {CardPool} from "../../models/pool";
import {draw, drawN} from "../../util/deal";
import * as admin from "firebase-admin";
import FieldValue = admin.firestore.FieldValue;
import {TurnWinner} from "../../models/turn";
import Timestamp = admin.firestore.Timestamp;

/**
 * Fetch a {@link Game} object by it's {gameId}
 * @param {string} gameId the document id of the game to pull
 */
export async function getGame(gameId: string): Promise<Game | undefined> {
  const gameDocSnapshot = await firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .get();

  const game = gameDocSnapshot.data() as Game;
  game.id = gameDocSnapshot.id;
  return game;
}

/**
 * Fetch a {@link Game} object by it's {gameId}
 * @param {admin.firestore.Transaction} transaction the transaction to fetch this game in
 * @param {string} gameId the document id of the game to pull
 */
export async function getGameByTransaction(
  transaction: admin.firestore.Transaction,
  gameId: string
): Promise<Game | undefined> {
  const gameDoc = firestore.collection(COLLECTION_GAMES).doc(gameId);

  const snapshot = await transaction.get(gameDoc);
  if (snapshot.exists) {
    const game = snapshot.data() as Game;
    game.id = snapshot.id;
    return game;
  }
  return undefined;
}

/**
 * Fetch a {@link Game} object by it's {gameId}
 * @param {string} gameId the game invite code
 */
export async function findGame(gameId: string): Promise<Game | undefined> {
  const gameDocSnapshot = await firestore
    .collection(COLLECTION_GAMES)
    .where("gameId", "==", gameId)
    .limit(1)
    .get();

  if (!gameDocSnapshot.empty) {
    const doc = gameDocSnapshot.docs[0];
    const game = doc.data() as Game;
    game.id = doc.id;
    return game;
  }

  return undefined;
}

/**
 * Remove yourself from a game
 * @param {admin.firestore.Transaction} transaction
 * @param {string} uid
 * @param {Game} game
 */
export function leaveGame(
  transaction: admin.firestore.Transaction,
  uid: string,
  game: Game
) {
  const gameDoc = firestore.collection(COLLECTION_GAMES).doc(game.id);

  const playerDoc = gameDoc.collection(COLLECTION_PLAYERS).doc(uid);

  // Set your player to inactive
  transaction.update(playerDoc, {
    isInactive: true,
  });

  // Delete your responses from the current turn
  if (game.turn?.responses?.[uid]) {
    delete game.turn.responses[uid];
  }

  // Remove yourself from the judging rotation and responses
  transaction.update(gameDoc, {
    "judgeRotation": FieldValue.arrayRemove(uid),
    "turn.responses": game.turn?.responses || {},
  });
}

/**
 * Fetch all the {@link Player}s for a {@link Game} by the {gameId}
 * @param {string} gameId the id of the game to get all the players for
 */
export async function getPlayers(
  gameId: string
): Promise<Player[] | undefined> {
  const playerCollection = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_PLAYERS);

  const playersSnapshot = await playerCollection.get();
  return playersSnapshot.docs.map((snapshot) => snapshot.data() as Player);
}

/**
 * Fetch all the {@link Player}s for a {@link Game} by the {gameId}
 * @param {admin.firestore.Transaction} transaction
 * @param {string} gameId the id of the game to get all the players for
 */
export async function getPlayersByTransaction(
  transaction: admin.firestore.Transaction,
  gameId: string
): Promise<Player[] | undefined> {
  const playerCollection = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_PLAYERS);

  const querySnapshot = await transaction.get(playerCollection);
  if (!querySnapshot.empty) {
    return querySnapshot.docs.map((snapshot) => snapshot.data() as Player);
  }

  return undefined;
}

/**
 * Fetch a {@link Player} for a {@link Game} by the {gameId}
 * @param {string} gameId the id of the game to get all the players for
 * @param {string} playerId the id of the player to fetch
 */
export async function getPlayer(
  gameId: string,
  playerId: string
): Promise<Player | undefined> {
  const playerDoc = await firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_PLAYERS)
    .doc(playerId);

  const playerSnapshot = await playerDoc.get();
  return playerSnapshot.data() as Player;
}

/**
 * Draw a new prompt card from the game pool by removing it
 * @param {string} gameId the game id to draw from
 */
export async function drawPromptCard(gameId: string): Promise<PromptCard> {
  const promptCardPool = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_CARD_POOL)
    .doc(DOCUMENT_PROMPTS);

  const prompts = await promptCardPool.get();
  const promptPool = prompts.data() as CardPool;
  const promptCardIndex = draw(promptPool.cards);

  // Now save the pool of cards
  await promptCardPool.update(promptPool);

  // now fetch the actual prompt card
  return cards.getPromptCard(promptCardIndex);
}

/**
 *
 * @param {string} gameId
 */
export async function getResponseCardPool(gameId: string): Promise<CardPool> {
  const responseCardPool = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_CARD_POOL)
    .doc(DOCUMENT_RESPONSES);

  const responses = await responseCardPool.get();
  return responses.data() as CardPool;
}

/**
 * Draw a {@param count} of cards from the game's response card pool
 * @param {string} gameId the id of the game to pull from
 * @param {number} count the number of response cards to draw
 */
export async function drawResponseCards(
  gameId: string,
  count: number
): Promise<ResponseCard[]> {
  const responseCardPool = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_CARD_POOL)
    .doc(DOCUMENT_RESPONSES);

  const responses = await responseCardPool.get();
  const responsePool = responses.data() as CardPool;
  const responseCardIndexes = drawN(responsePool.cards, count);

  await responseCardPool.update(responsePool);

  return cards.getResponseCards(responseCardIndexes);
}

/**
 * Submit response cards to a current game
 *
 * @param {admin.firestore.Transaction} transaction
 * @param {string} gameId
 * @param {string} playerId
 * @param {ResponseCard[]} responseCards
 */
export function submitResponseCards(
  transaction: admin.firestore.Transaction,
  gameId: string,
  playerId: string,
  responseCards: ResponseCard[]
) {
  const gameDoc = firestore.collection(COLLECTION_GAMES).doc(gameId);

  transaction.update(gameDoc, {
    [`turn.responses.${playerId}`]: responseCards,
  });
}

/**
 * Return all current responses of the current turn to their respective player's since we are likely
 * resetting the turn and giving responses back
 * @param {string} gameId the document id of the game
 * @param {Game} game the game in which to return responses for, if the current turn is valid
 */
export async function returnResponseCards(
  gameId: string,
  game: Game
): Promise<void> {
  if (game.turn) {
    const playerCollection = firestore
      .collection(COLLECTION_GAMES)
      .doc(gameId)
      .collection(COLLECTION_PLAYERS);

    await firestore.runTransaction(async (transaction) => {
      for (const [playerId, responses] of Object.entries<ResponseCard[]>(
        game.turn!.responses
      )) {
        if (playerId !== RANDO_CARDRISSIAN) {
          const playerDoc = playerCollection.doc(playerId);
          transaction.update(playerDoc, {
            hand: FieldValue.arrayUnion(...responses),
          });
        }
      }
    });
  }
}

/**
 *
 * @param {string} gameId
 * @param {PromptCard} promptCard
 */
export async function storeVetoedPromptCard(
  gameId: string,
  promptCard: PromptCard
): Promise<void> {
  const vetoedDoc = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_VETOED)
    .doc();

  await vetoedDoc.set({
    ...promptCard,
    vetoedAt: Timestamp.now(),
  });
}

/**
 *
 * @param {string} gameId
 */
export async function clearDownvotes(gameId: string) {
  const tallyDoc = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_DOWNVOTES)
    .doc(DOCUMENT_TALLY);

  await tallyDoc.set({
    votes: [],
  });
}

/**
 * Update the game state, specifying what you want to udpate with
 *
 * @see admin.firestore.DocumentReference#update
 * @param {string} gameId the game to update
 * @param {FirebaseFirestore.UpdateData<any>} data the data to update
 */
export async function update(
  gameId: string,
  data: FirebaseFirestore.UpdateData<any>
) {
  const gameDoc = firestore.collection(COLLECTION_GAMES).doc(gameId);

  await gameDoc.update(data);
}

/**
 * Update the game state, specifying what you want to udpate with
 *
 * @see admin.firestore.DocumentReference#update
 * @param {admin.firestore.Transaction} transaction the firestore transaction to update in
 * @param {string} gameId the game to update
 * @param {FirebaseFirestore.UpdateData<any>} data the data to update
 */
export function updateByTransaction(
  transaction: admin.firestore.Transaction,
  gameId: string,
  data: FirebaseFirestore.UpdateData<any>
) {
  const gameDoc = firestore.collection(COLLECTION_GAMES).doc(gameId);

  // TODO: datat should be data.data (?)
  transaction.update(gameDoc, data);
}

/**
 * Update the {@link Game} state
 * @param {string} gameId the game to update
 * @param {FirebaseFirestore.UpdateData<any>} data the game state data to update
 * @param {Player[]} players the list of players to update their state of
 */
export async function updateStateWithData(
  gameId: string,
  data: FirebaseFirestore.UpdateData<any>,
  players: Player[] = []
): Promise<void> {
  if (!data["gameStatus"]) {
    throw Error("You must pass a state when updating this way");
  }

  const gameDoc = firestore.collection(COLLECTION_GAMES).doc(gameId);

  await gameDoc.update(data);

  // We should also update all the UserGame states for every player connected to the game
  if (players.length > 0) {
    for (const player of players) {
      if (!player.isRandoCardrissian) {
        const playerUserGameDoc = firestore
          .collection(COLLECTION_USERS)
          .doc(player.id)
          .collection(COLLECTION_GAMES)
          .doc(gameId);

        try {
          await playerUserGameDoc.update({
            gameStatus: data["gameStatus"],
          });
        } catch (e) {
          console.log(`Unable to update player's game state: ${e}`);
        }
      }
    }
  }
}

/**
 *
 * @param {admin.firestore.Transaction} transaction
 * @param {string} gameId
 * @param {string} userId
 */
export function addToJudgeRotation(
  transaction: admin.firestore.Transaction,
  gameId: string,
  userId: string
) {
  const gameDoc = firestore.collection(COLLECTION_GAMES).doc(gameId);

  transaction.update(gameDoc, {
    judgeRotation: FieldValue.arrayUnion(userId),
  });
}

/**
 * Update the {@link Game} state
 * @param {string} gameId the game to update
 * @param {GameStatus} gameStatus the state to update to
 * @param {Player[]} players the list of players to update their state of
 */
export async function updateState(
  gameId: string,
  gameStatus: GameStatus,
  players: Player[] = []
): Promise<void> {
  return updateStateWithData(
    gameId,
    {
      gameStatus: gameStatus,
    },
    players
  );
}

/**
 *
 * @param {Game} game
 * @param {TurnWinner} turnWinner
 */
export async function storeTurn(
  game: Game,
  turnWinner: TurnWinner
): Promise<void> {
  if (game.turn) {
    const turnDoc = firestore
      .collection(COLLECTION_GAMES)
      .doc(game.id)
      .collection(COLLECTION_TURNS)
      .doc(`${game.round}`);

    const turn = game.turn;
    turn.winner = turnWinner;

    await turnDoc.set({
      ...turn,
      createdAt: Timestamp.now(),
    });
  }
}

/**
 * Seed a {@link Game} card pool with an array of prompt and response card id indexes
 *
 * @param {string} gameId the id of the {@link Game} to seed
 * @param {string[]} promptCardIndexes the array of prompt card indexes to set
 * @param {string[]} responseCardIndexes the array of response card indexes to set
 */
export async function seedCardPool(
  gameId: string,
  promptCardIndexes: string[] = [],
  responseCardIndexes: string[] = []
): Promise<void> {
  if (promptCardIndexes.length > 0 && responseCardIndexes.length > 0) {
    console.log(`Seeding Game(${gameId}) Card Pool`);
  }
  console.log(`Prompts: ${promptCardIndexes}`);
  console.log(`Responses: ${responseCardIndexes}`);

  const cardPoolCollection = firestore
    .collection(COLLECTION_GAMES)
    .doc(gameId)
    .collection(COLLECTION_CARD_POOL);

  if (promptCardIndexes.length > 0) {
    await cardPoolCollection.doc(DOCUMENT_PROMPTS).set({
      cards: promptCardIndexes ?? [],
    });
  }

  if (responseCardIndexes.length > 0) {
    await cardPoolCollection.doc(DOCUMENT_RESPONSES).set({
      cards: responseCardIndexes ?? [],
    });
  }
}
