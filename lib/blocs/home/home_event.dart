part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {}

class JoinGame extends HomeEvent {
  final String gameCode;

  const JoinGame({
    required this.gameCode,
  });

  @override
  List<Object?> get props => [
        gameCode,
      ];
}

class JoinedGamesUpdated extends HomeEvent {
  final List<UserGame> games;

  const JoinedGamesUpdated({
    required this.games,
  });

  @override
  List<Object?> get props => [
        games,
      ];
}

class CloseHomeStreams extends HomeEvent {}

class LeaveGame extends HomeEvent {
  final UserGame game;

  const LeaveGame({
    required this.game,
  });

  @override
  List<Object?> get props => [
        game,
      ];
}

class RefreshHome extends HomeEvent {
  const RefreshHome();

  @override
  List<Object?> get props => [];
}

class UserUpdatedViaHome extends HomeEvent {
  final User user;

  const UserUpdatedViaHome({
    required this.user,
  });

  @override
  List<Object?> get props => [
        user,
      ];
}
