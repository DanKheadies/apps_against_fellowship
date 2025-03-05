import 'dart:async';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'game_event.dart';
part 'game_state.dart';

// class GameBloc extends HydratedBloc<GameEvent, GameState> {
class GameBloc extends Bloc<GameEvent, GameState> {
  final AuthRepository _authRepository;
  final GameRepository _gameRepository;
  final UserBloc _userBloc;
  StreamSubscription? _gameSubcription;
  StreamSubscription? _playersSubscription;
  StreamSubscription? _downvoteSubscription;

  GameBloc({
    required AuthRepository authRepository,
    required GameRepository gameRepository,
    required UserBloc userBloc,
  })  : _authRepository = authRepository,
        _gameRepository = gameRepository,
        _userBloc = userBloc,
        super(const GameState()) {
    // super(GameState.empty()) {
    on<ClearError>(_onClearError);
    on<ClearPickedResponseCards>(_onClearPickedResponseCards);
    on<ClearKicking>(_onClearKicking);
    on<DownvotePrompt>(_onDownvotePrompt);
    on<DownvotesUpdated>(_onDownvotesUpdated);
    on<GameUpdated>(_onGameUpdated);
    on<KickPlayer>(_onKickPlayer);
    on<OpenGame>(_onOpenGame);
    on<PickResponseCard>(_onPickResponseCard);
    on<PickWinner>(_onPickWinner);
    on<PlayersUpdated>(_onPlayersUpdated);
    on<ReDealHand>(_onReDealHand);
    on<StartGame>(_onStartGame);
    on<SubmitResponses>(_onSubmitResponses);
    on<Subscribe>(_onSubscribe);
    on<UserUpdated>(_onUserUpdated);
    on<WaveAtPlayer>(_onWaveAtPlayer);
  }

  void _onClearError(
    ClearError event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        error: '',
        gameStateStatus: GameStateStatus.goodToGo,
      ),
    );
  }

  void _onClearPickedResponseCards(
    ClearPickedResponseCards event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCards: [],
        // error: 'Test error',
        // gameStateStatus: GameStateStatus.error,
      ),
    );
  }

  void _onClearKicking(
    ClearKicking event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        gameStateStatus: GameStateStatus.goodToGo,
        kickingPlayerId: '',
      ),
    );
  }

  void _onDownvotePrompt(
    DownvotePrompt event,
    Emitter<GameState> emit,
  ) async {
    try {
      await _gameRepository.downVoteCurrentPrompt(
        state.game.id,
        _userBloc.state.user,
      );

      emit(
        state.copyWith(
          gameStateStatus: GameStateStatus.goodToGo,
        ),
      );
    } catch (err) {
      print('error downvoting prompt');
      emit(
        state.copyWith(
          error: '$err',
          gameStateStatus: GameStateStatus.error,
        ),
      );
    }
  }

  void _onDownvotesUpdated(
    DownvotesUpdated event,
    Emitter<GameState> emit,
  ) {
    // print('g2g3');
    emit(
      state.copyWith(
        downvotes: event.downvotes,
        // gameStateStatus: GameStateStatus.goodToGo, // TODO
      ),
    );
  }

  void _onGameUpdated(
    GameUpdated event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: event.game,
        // gameStateStatus: GameStateStatus.goodToGo, // TODO
        // Note: if we don't g2g here, the sub can crunching and eventually
        // get the players, which we can trigger as g2g. Not sure if that's
        // ideal, but lets try it.
      ),
    );
  }

  void _onKickPlayer(
    KickPlayer event,
    Emitter<GameState> emit,
  ) async {
    _checkAndEmit(emit, GameStateStatus.loading);

    try {
      await _gameRepository.kickPlayer(
        state.game.id,
        event.playerId,
        _userBloc.state.user.id,
      );

      emit(
        state.copyWith(
          gameStateStatus: GameStateStatus.loading,
          kickingPlayerId: '',
        ),
      );
    } catch (err) {
      print('kicking player err: $err');

      emit(
        state.copyWith(
          error: err.toString(),
          gameStateStatus: GameStateStatus.error,
          kickingPlayerId: '',
        ),
      );
    }
  }

  void _onOpenGame(
    OpenGame event,
    Emitter<GameState> emit,
  ) async {
    _checkAndEmit(emit, GameStateStatus.loading);

    try {
      var existingGame = await _gameRepository.getGame(
        event.gameId,
        event.user,
      );

      add(
        GameUpdated(game: existingGame),
      );
      add(
        Subscribe(gameId: existingGame.id),
      );

      emit(
        state.copyWith(
          game: existingGame,
          gameStateStatus: GameStateStatus.goodToGo,
        ),
      );
    } catch (err) {
      print('opening game err: $err');

      emit(
        state.copyWith(
          error: err.toString(),
          gameStateStatus: GameStateStatus.error,
        ),
      );
    }
  }

  void _onPickResponseCard(
    PickResponseCard event,
    Emitter<GameState> emit,
  ) {
    // Check prompt special to determine if we allow the user to pick two
    var special = promptSpecial(state.game.turn!.promptCard.special);
    if (special != PromptSpecial.notSpecial) {
      // With a special there is the opportunity to submit more than 1 card.
      // If the user attempts to select more than the allotted amount for a give
      // prompt special, it will clear the selected and set the picked card as
      // the only one effectively starting the selection over.
      var currentSelection = state.selectedCards.toList();
      switch (special) {
        case PromptSpecial.pick2:
          // Selected size limit is 2 here.
          if (currentSelection.length < 2) {
            emit(
              state.copyWith(
                selectedCards: currentSelection..add(event.card),
              ),
            );
          } else {
            emit(
              state.copyWith(
                selectedCards: [event.card],
              ),
            );
          }
          break;
        case PromptSpecial.draw2pick3:
          // Selected size limit is 3 here. The firebase function that deals
          // with churning-turns will auto-matically deal out an extra 2 cards
          // to the user at turn start.
          if (currentSelection.length < 3) {
            emit(
              state.copyWith(
                selectedCards: currentSelection..add(event.card),
              ),
            );
          } else {
            emit(
              state.copyWith(
                selectedCards: [event.card],
              ),
            );
          }
          break;
        default:
          break;
      }
    } else {
      // The lack of a special is an indication of PICK 1 only.
      emit(
        state.copyWith(
          selectedCards: [event.card],
        ),
      );
    }
  }

  void _onPickWinner(
    PickWinner event,
    Emitter<GameState> emit,
  ) async {
    _checkAndEmit(emit, GameStateStatus.loading);

    try {
      await _gameRepository.pickWinner(
        state.game.id,
        event.winningPlayerId,
        _userBloc.state.user.id,
      );

      emit(
        state.copyWith(
          gameStateStatus: GameStateStatus.goodToGo,
        ),
      );
    } catch (err) {
      // print('error picking a winner: $err');
      emit(
        state.copyWith(
          error: '$err',
          gameStateStatus: GameStateStatus.error,
        ),
      );
    }
  }

  void _onPlayersUpdated(
    PlayersUpdated event,
    Emitter<GameState> emit,
  ) {
    for (var player in event.players) {
      print(player.id);
      print(player.isInactive);
    }
    print(_userBloc.state.user.id);
    if (event.players.any((player) =>
        player.id == _userBloc.state.user.id && player.isInactive)) {
      print('we were kicked; leave game');
      emit(
        state.copyWith(
          kickingPlayerId: _userBloc.state.user.id,
        ),
      );
    }

    emit(
      state.copyWith(
        players: event.players,
      ),
    );
  }

  void _onReDealHand(
    ReDealHand event,
    Emitter<GameState> emit,
  ) async {
    _checkAndEmit(emit, GameStateStatus.redealing);

    try {
      await _gameRepository.reDealHand(event.gameDocId, event.userId);

      emit(
        state.copyWith(
          gameStateStatus: GameStateStatus.goodToGo,
        ),
      );
    } catch (err) {
      print('re-deal hand err: $err');
      emit(
        state.copyWith(
          error: 'There was an error re-dealing your hand.',
          gameStateStatus: GameStateStatus.error,
        ),
      );
    }
  }

  void _onStartGame(
    StartGame event,
    Emitter<GameState> emit,
  ) async {
    _checkAndEmit(emit, GameStateStatus.loading);

    try {
      await _gameRepository.startGame(
        state.game.id,
        _userBloc.state.user.id,
      );

      emit(
        state.copyWith(
          gameStateStatus: GameStateStatus.goodToGo,
        ),
      );
    } catch (err) {
      if (err is PlatformException) {
        print(err);
        if (err.code == 'functionsError') {
          final Map<String, dynamic> details =
              Map<String, dynamic>.from(err.details);

          emit(
            state.copyWith(
              error: details['message'],
              gameStateStatus: GameStateStatus.error,
            ),
          );
        }
      } else {
        print('other error starting game');
        emit(
          state.copyWith(
            error: 'There was an error starting the game.',
            gameStateStatus: GameStateStatus.error,
          ),
        );
        throw Exception(err);
      }
    }
  }

  void _onSubmitResponses(
    SubmitResponses event,
    Emitter<GameState> emit,
  ) async {
    _checkAndEmit(emit, GameStateStatus.submitting);

    if (state.selectedCards.isNotEmpty) {
      try {
        await _gameRepository.submitResponse(
          state.game.id,
          _userBloc.state.user.id,
          state.selectedCards,
        );

        emit(
          state.copyWith(
            selectedCards: [],
            gameStateStatus: GameStateStatus.goodToGo,
          ),
        );
      } catch (err) {
        print('error submitting responses: $err');
        emit(
          state.copyWith(
            error: '$err',
            gameStateStatus: GameStateStatus.error,
          ),
        );
      }
    }
  }

  void _onSubscribe(
    Subscribe event,
    Emitter<GameState> emit,
  ) {
    var user = _authRepository.getUser();
    add(
      UserUpdated(
        userId: user!.uid,
      ),
    );

    _gameSubcription?.cancel();
    _gameSubcription = _gameRepository.observeGame(event.gameId).listen((game) {
      add(
        GameUpdated(
          game: game,
        ),
      );
      add(
        UserUpdated(
          userId: user.uid,
        ),
      );
    });

    _playersSubscription?.cancel();
    _playersSubscription =
        _gameRepository.observePlayers(event.gameId).listen((players) {
      print('observing players..');
      add(
        PlayersUpdated(
          players: players,
        ),
      );
    });

    _downvoteSubscription?.cancel();
    _downvoteSubscription =
        _gameRepository.observeDownvotes(event.gameId).listen((downvotes) {
      add(
        DownvotesUpdated(
          downvotes: downvotes,
        ),
      );
    });
  }

  void _onUserUpdated(
    UserUpdated event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        userId: event.userId,
      ),
    );
  }

  void _onWaveAtPlayer(
    WaveAtPlayer event,
    Emitter<GameState> emit,
  ) async {
    _checkAndEmit(emit, GameStateStatus.waving);

    try {
      await _gameRepository.waveAtPlayer(
        state.game.id,
        event.playerId,
        _userBloc.state.user.id,
      );

      emit(
        state.copyWith(
          gameStateStatus: GameStateStatus.goodToGo,
        ),
      );
    } catch (err) {
      print('error waving');
      emit(
        state.copyWith(
          error: '$err',
          gameStateStatus: GameStateStatus.error,
        ),
      );
    }
  }

  void _checkAndEmit(
    Emitter<GameState> emit,
    GameStateStatus status,
  ) {
    print('check for $status');
    if (state.gameStateStatus == status) return;
    print('emitting: $status');
    emit(
      state.copyWith(
        gameStateStatus: status,
      ),
    );
  }

  @override
  Future<void> close() {
    _downvoteSubscription?.cancel();
    _downvoteSubscription = null;
    _gameSubcription?.cancel();
    _gameSubcription = null;
    _playersSubscription?.cancel();
    _playersSubscription = null;
    return super.close();
  }

  // @override
  // GameState? fromJson(Map<String, dynamic> json) {
  //   return GameState.fromJson(json);
  // }

  // @override
  // Map<String, dynamic>? toJson(GameState state) {
  //   print('gameBloc toJson');
  //   print(state);
  //   return state.toJson();
  // }
}
