/* eslint-disable max-len */
import {Turn} from "./turn";

/**
 * Represents the game object in Firestore
 * Resource: `/games/{game_id}`
 */
export type Game = {
  id: string;
  gameId: string;
  ownerId: string;
  gameStatus: GameStatus;
  round: number;
  prizesToWin: number;
  playerLimit: number;
  pick2Enabled?: boolean;
  draw2Pick3Enabled?: boolean;
  judgeRotation: string[];
  cardSets: string[];
  turn?: Turn;
  winner?: string;
};

export declare type GameStatus =
  | "waitingRoom"
  | "starting"
  | "inProgress"
  | "gameOver"
  | "completed";

/**
 * Get the next judge in the game's judge rotation for the given judge id
 *
 * @param {Game} game the game to process
 * @param {string} currentJudgeId the current judge id
 * @return {string}
 */
export function nextJudge(game: Game, currentJudgeId: string): string {
  const currentJudgeIndex = game.judgeRotation.indexOf(currentJudgeId)!;
  if (currentJudgeIndex < game.judgeRotation!.length - 1) {
    return game.judgeRotation![currentJudgeIndex + 1];
  } else {
    return game.judgeRotation![0];
  }
}
