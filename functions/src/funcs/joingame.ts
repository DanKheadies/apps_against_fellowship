/* eslint-disable max-len */
// import { CallableContext } from "firebase-functions/lib/common/providers/https";
import * as firebase from "../firebase/firebase";
import {error} from "../util/error";
import {Player} from "../models/player";
import {UserGame} from "../models/usergame";
import {none} from "../util/array";
import {Game} from "../models/game";

/**
 * Join Game - [Callable Function]
 * This function manages player's joining games and setting their state correctly
 *
 * @param {any} data
 */
export async function handleJoinGame(data: any) {
  const uid = data.data["uid"];
  const gameId = data.data["game_id"];
  const gameDocId = data.data["game_doc_id"];
  let name = data.data["name"];
  const avatar = data.data["avatar"];

  if (!uid) {
    error("unauthenticated", "You must be authenticated to use this endpoint");
  }
  if (!gameId && !gameDocId) {
    error("invalid-argument", "You must specify a valid game code or id");
  }
  if (!name) {
    name = `Player-${uid.slice(0, 5)}`;
    console.log(`A player has no name. So we give him ${name}`);
  }

  // TODO: This would be a good point to set a 'default' avatar

  // Check the game document id first
  let game: Game | undefined;
  if (gameDocId) {
    game = await firebase.games.getGame(gameDocId);
  } else if (gameId) {
    game = await firebase.games.findGame(gameId);
  }
  if (game) {
    // Game completed, deny request
    if (game.gameStatus === "completed") {
      error("invalid-argument", "This game has already completed");
    }

    // Game is starting, deny request
    if (game.gameStatus === "starting") {
      error("cancelled", "This game is currently starting, please try again");
    }

    const players = await firebase.games.getPlayers(game.id);
    if ((players?.length || 0) < (game.playerLimit || 30)) {
      console.log("Player limit is NOT met, add player to game");
      await firebase.firestore.runTransaction(async (transaction) => {
        const player: Player = {
          id: uid,
          name: name,
          avatarUrl: avatar,
          isInactive: false,
          isRandoCardrissian: false,
        };
        firebase.players.joinGame(transaction, game.id, player);

        // Create User Game Record on player obj
        const userGame: UserGame = {
          id: game.id,
          gameId: game.gameId,
          gameStatus: game.gameStatus,
          joinedAt: new Date().toISOString(),
        };
        firebase.players.createUserGame(transaction, uid, game!.id, userGame);

        // If game is in-progress, then be sure to add this person to the judging order
        if (game!.gameStatus === "inProgress") {
          if (
            game!.judgeRotation &&
            none(game!.judgeRotation, (id) => id === uid)
          ) {
            console.log(
              `Adding User(${uid}) to the Judge Rotation for Game(${game!.id})`
            );
            firebase.games.addToJudgeRotation(transaction, game!.id, uid);
          }

          // Also check if we need to deal them into the ongoing game
          const existingPlayer = players?.find((p) => p.id === uid);
          if (!existingPlayer) {
            // We are here because we have likely just added this player to an ongoing game, which means
            // that they lack the cards to play so we should deal them a new hand

            // 1. Pull the card pool for this game
            const newHand = await firebase.games.drawResponseCards(
              game!.id,
              10
            );
            firebase.players.setHandByTransaction(
              transaction,
              game!.id,
              uid,
              newHand
            );
            console.log(
              `Dealing the new user(${player.name}) a freshly picked hand`
            );
          }
        }

        // Notify game owner that someone has joined their game
        if (uid !== game!.ownerId) {
          // TODO: convert to subscription topic then re-activate
          // await firebase.push.sendPlayerJoinedMessage(game!, name);
        }
      });

      return game;
    } else {
      error(
        "unavailable",
        `This Game, ${gameId}, is already full. Cannot join.`
      );
    }
  } else {
    error("not-found", `Couldn't find a game for the Code: ${gameId}`);
  }
}
