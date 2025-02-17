import {GameStatus} from "./game";

export type UserGame = {
  id?: string;
  gameId: string;
  joinedAt: string;
  gameStatus: GameStatus;
};
