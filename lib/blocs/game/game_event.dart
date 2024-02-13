part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class ClearError extends GameEvent {}

class ClearPickedResponseCards extends GameEvent {}

class ClearSubmitting extends GameEvent {}

class DownvotePrompt extends GameEvent {}

class DownvotesUpdated extends GameEvent {
  final List<String> downvotes;

  const DownvotesUpdated({
    required this.downvotes,
  });

  @override
  List<Object> get props => [
        downvotes,
      ];
}

class GameUpdated extends GameEvent {
  final Game game;

  const GameUpdated({
    required this.game,
  });

  @override
  List<Object> get props => [
        game,
      ];
}

class KickPlayer extends GameEvent {
  final String playerId;

  const KickPlayer({
    required this.playerId,
  });

  @override
  List<Object> get props => [
        playerId,
      ];
}

class PlayersUpdated extends GameEvent {
  final List<Player> players;

  const PlayersUpdated({
    required this.players,
  });

  @override
  List<Object> get props => [
        players,
      ];
}

class PickResponseCard extends GameEvent {
  final ResponseCard card;

  const PickResponseCard({
    required this.card,
  });

  @override
  List<Object> get props => [
        card,
      ];
}

class PickWinner extends GameEvent {
  final String winningPlayerId;

  const PickWinner({
    required this.winningPlayerId,
  });

  @override
  List<Object> get props => [
        winningPlayerId,
      ];
}

class StartGame extends GameEvent {}

class SubmitResponses extends GameEvent {}

class Subscribe extends GameEvent {
  final String gameId;

  const Subscribe({
    required this.gameId,
  });

  @override
  List<Object> get props => [
        gameId,
      ];
}

class UserUpdated extends GameEvent {
  final String userId;

  const UserUpdated({
    required this.userId,
  });

  @override
  List<Object> get props => [
        userId,
      ];
}

class WaveAtPlayer extends GameEvent {
  final String message;
  final String playerId;

  const WaveAtPlayer({
    required this.message,
    required this.playerId,
  });

  @override
  List<Object> get props => [
        message,
        playerId,
      ];
}
