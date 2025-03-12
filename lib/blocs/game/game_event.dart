part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class ClearError extends GameEvent {}

class ClearPickedResponseCards extends GameEvent {}

class ClearKicking extends GameEvent {}

class CloseGameStreams extends GameEvent {}

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

class OpenGame extends GameEvent {
  final bool? fromNav;
  final String gameId;
  final User user;

  const OpenGame({
    required this.gameId,
    required this.user,
    this.fromNav = false,
  });

  @override
  List<Object?> get props => [
        gameId,
        fromNav,
        user,
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

class ReDealHand extends GameEvent {
  final String gameDocId;
  final String userId;

  const ReDealHand({
    required this.gameDocId,
    required this.userId,
  });

  @override
  List<Object> get props => [
        gameDocId,
        userId,
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
