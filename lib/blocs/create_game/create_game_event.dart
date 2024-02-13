part of 'create_game_bloc.dart';

abstract class CreateGameEvent extends Equatable {
  const CreateGameEvent();

  @override
  List<Object> get props => [];
}

class CardSetSelected extends CreateGameEvent {
  final CardSet cardSet;

  const CardSetSelected({
    required this.cardSet,
  });

  @override
  List<Object> get props => [
        cardSet,
      ];
}

class CardSourceSelected extends CreateGameEvent {
  final bool isAllChecked;
  final String source;

  const CardSourceSelected({
    required this.isAllChecked,
    required this.source,
  });

  @override
  List<Object> get props => [
        isAllChecked,
        source,
      ];
}

class ChangePrizesToWin extends CreateGameEvent {
  final int prizesToWin;

  const ChangePrizesToWin({
    required this.prizesToWin,
  });

  @override
  List<Object> get props => [
        prizesToWin,
      ];
}

class ChangePlayerLimit extends CreateGameEvent {
  final int playerLimit;

  const ChangePlayerLimit({
    required this.playerLimit,
  });

  @override
  List<Object> get props => [
        playerLimit,
      ];
}

class ChangePick2Enabled extends CreateGameEvent {
  final bool enabled;

  const ChangePick2Enabled({
    required this.enabled,
  });

  @override
  List<Object> get props => [
        enabled,
      ];
}

class ChangeDraw2Pick3Enabled extends CreateGameEvent {
  final bool enabled;

  const ChangeDraw2Pick3Enabled({
    required this.enabled,
  });

  @override
  List<Object> get props => [
        enabled,
      ];
}

class CreateGame extends CreateGameEvent {}

class LoadCreateGame extends CreateGameEvent {}
