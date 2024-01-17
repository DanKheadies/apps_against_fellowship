part of 'game_bloc.dart';

// enum GameStatus {
//   completed,
//   inProgress,
//   starting,
//   waitingRoom,
// }

class GameState extends Equatable {
  final Game game;
  final GameStatus gameStatus;

  const GameState({
    this.game = Game.emptyGame,
    this.gameStatus = GameStatus.waitingRoom,
  });

  @override
  List<Object?> get props => [
        game,
        gameStatus,
      ];

  GameState copyWith({
    Game? game,
    GameStatus? gameStatus,
  }) {
    return GameState(
      game: game ?? this.game,
      gameStatus: gameStatus ?? this.gameStatus,
    );
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      game: Game.fromJson(json['game']),
      gameStatus: GameStatus.values.firstWhere(
        (status) => status.name.toString() == json['gameStatus'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game': game.toJson(),
      'gameStatus': gameStatus.name,
    };
  }
}
