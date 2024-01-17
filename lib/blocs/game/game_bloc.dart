import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:apps_against_fellowship/models/models.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends HydratedBloc<GameEvent, GameState> {
  final Game _initialGame;
  // final GameRepository gameRepository;

  // StreamSubscription _gameSubcription;
  // StreamSubscription? _playersSubscription;
  // StreamSubscription? _downvoteSubscription;

  GameBloc({
    required Game initialGame,
    // required GameRepository gameRepository,
  })  : _initialGame = initialGame,
        super(const GameState()) {
    on<ClearError>(_onClearError);
    on<ClearPickedResponseCards>(_onClearPickedResponseCards);
    on<ClearSubmitting>(_onClearSubmitting);
    on<DownvotePrompt>(_onDownvotePrompt);
    on<DownvotesUpdated>(_onDownvotesUpdated);
    on<GameUpdated>(_onGameUpdated);
    on<KickPlayer>(_onKickPlayer);
    on<PickResponseCard>(_onPickResponseCard);
    on<PickWinner>(_onPickWinner);
    on<PlayersUpdated>(_onPlayersUpdated);
    on<StartGame>(_onStartGame);
    on<SubmitResponses>(_onSubmitResponses);
    on<Subscribe>(_onSubscribe);
    on<UserUpdated>(_onUserUpdated);
    on<WaveAtPlayer>(_onWaveAtPlayer);
  }

  void _onSubscribe(
    Subscribe event,
    Emitter<GameState> emit,
  ) {}

  void _onUserUpdated(
    UserUpdated event,
    Emitter<GameState> emit,
  ) {}

  void _onGameUpdated(
    GameUpdated event,
    Emitter<GameState> emit,
  ) {}

  void _onPlayersUpdated(
    PlayersUpdated event,
    Emitter<GameState> emit,
  ) {}

  void _onDownvotesUpdated(
    DownvotesUpdated event,
    Emitter<GameState> emit,
  ) {}

  void _onStartGame(
    StartGame event,
    Emitter<GameState> emit,
  ) {}

  void _onClearError(
    ClearError event,
    Emitter<GameState> emit,
  ) {}

  void _onDownvotePrompt(
    DownvotePrompt event,
    Emitter<GameState> emit,
  ) {}

  void _onWaveAtPlayer(
    WaveAtPlayer event,
    Emitter<GameState> emit,
  ) {}

  void _onPickResponseCard(
    PickResponseCard event,
    Emitter<GameState> emit,
  ) {}

  void _onClearPickedResponseCards(
    ClearPickedResponseCards event,
    Emitter<GameState> emit,
  ) {}

  void _onSubmitResponses(
    SubmitResponses event,
    Emitter<GameState> emit,
  ) {}

  void _onPickWinner(
    PickWinner event,
    Emitter<GameState> emit,
  ) {}

  void _onKickPlayer(
    KickPlayer event,
    Emitter<GameState> emit,
  ) {}

  void _onClearSubmitting(
    ClearSubmitting event,
    Emitter<GameState> emit,
  ) {}

  @override
  GameState? fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic>? toJson(GameState state) {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
