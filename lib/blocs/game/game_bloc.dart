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
    on<ClearSubmitting>(_onClearSubmitting);
    on<DownvotePrompt>(_onDownvotePrompt);
    on<DownvotesUpdated>(_onDownvotesUpdated);
    on<GameUpdated>(_onGameUpdated);
    on<KickPlayer>(_onKickPlayer);
    on<OpenGame>(_onOpenGame);
    on<PickResponseCard>(_onPickResponseCard);
    on<PickWinner>(_onPickWinner);
    on<PlayersUpdated>(_onPlayersUpdated);
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
        error: null,
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
      ),
    );
  }

  void _onClearSubmitting(
    ClearSubmitting event,
    Emitter<GameState> emit,
  ) {
    // TODO
    print('g2g1');
    emit(
      state.copyWith(
        gameStateStatus: GameStateStatus.goodToGo,
      ),
    );
  }

  void _onDownvotePrompt(
    DownvotePrompt event,
    Emitter<GameState> emit,
  ) async {
    emit(
      state.copyWith(
        gameStateStatus: GameStateStatus.downvoting, // TODO: loading (?)
      ),
    );

    try {
      await _gameRepository.downVoteCurrentPrompt(
        state.game.id,
        _userBloc.state.user,
      );

      print('g2g2');
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
  ) {}

  void _onOpenGame(
    OpenGame event,
    Emitter<GameState> emit,
  ) async {
    if (state.gameStateStatus == GameStateStatus.loading) return;

    emit(
      state.copyWith(
        gameStateStatus: GameStateStatus.loading,
      ),
    );

    try {
      // print('open game');
      var existingGame = await _gameRepository.getGame(
        event.gameId,
        event.user,
      );

      // print('have game');
      // print(event.gameId);
      // print(existingGame);
      add(
        GameUpdated(game: existingGame),
      );
      add(
        Subscribe(gameId: existingGame.id),
      );

      print('g2g4');
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
    // TODO: emit a status (?)
    print('pick response card; TODO emit?');

    // Check prompt special to determine if we allow the user to pick two
    var special = promptSpecial(state.game.turn!.promptCard.special);
    if (special != PromptSpecial.notSpecial) {
      // With a special there is the opportunity to submit more than 1 card.
      // If the user attempts to select more than the allotted amount for a give
      // prompt special, it will clear the selected and set the picked card as
      // the only one effectively starting the selection over.
      var currentSelection = state.selectedCards;
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
    // Note: was submitting; now loading
    if (state.gameStateStatus == GameStateStatus.loading) return;

    emit(
      state.copyWith(
        gameStateStatus: GameStateStatus.loading,
      ),
    );

    try {
      await _gameRepository.pickWinner(
        state.game.id,
        event.winningPlayerId,
        _userBloc.state.user.id,
      );

      print('g2g5');
      emit(
        state.copyWith(
          gameStateStatus: GameStateStatus.goodToGo,
        ),
      );
    } catch (err) {
      print('error picking a winner: $err');
      emit(
        state.copyWith(
          error: '$err',
          gameStateStatus: GameStateStatus.error,
          kickingPlayerId: null,
        ),
      );
    }
  }

  void _onPlayersUpdated(
    PlayersUpdated event,
    Emitter<GameState> emit,
  ) {
    print('players updated');
    // print('g2g6');
    emit(
      state.copyWith(
        // gameStateStatus: GameStateStatus.goodToGo, // TODO
        // Note: have this be the g2g might simplify the "we don't have players"
        // issue, but honestly might not be needed / helpful here anyways, i.e.
        // we aren't looking for g2g anywhere in the code yet...
        players: event.players,
      ),
    );
  }

  void _onStartGame(
    StartGame event,
    Emitter<GameState> emit,
  ) async {
    // TODO: this should prob be loading or starting and not submitting
    // Note: changed to loading, which drives the Wait vs Start screen UI
    if (state.gameStateStatus == GameStateStatus.loading) return;

    emit(
      state.copyWith(
        gameStateStatus: GameStateStatus.loading,
      ),
    );

    try {
      await _gameRepository.startGame(
        state.game.id,
        _userBloc.state.user.id,
      );
      // function updates DB to inProgress when complete (sub/stream updates UI)
      // but should emit g2g here ?
      // TODO: make sure this works as expected
      // Seems to work fine w/ no change, but I think it's cuz something in the
      // Subscribe updates. Will prob want to re-activate here in a second...
      print('start game & emit; g2gX');
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
          print(details);
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
    if (state.gameStateStatus == GameStateStatus.submitting) return;

    emit(
      state.copyWith(
        gameStateStatus: GameStateStatus.submitting,
      ),
    );

    if (state.selectedCards.isNotEmpty) {
      try {
        await _gameRepository.submitResponse(
          state.game.id,
          _userBloc.state.user.id,
          state.selectedCards,
        );

        print('g2g7');
        emit(
          state.copyWith(
            selectedCards: [],
            gameStateStatus: GameStateStatus.goodToGo,
            // canPickWinner
            //     ? GameStateStatus.picking
            //     : GameStateStatus.goodToGo,
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
    print('subscribing to game..');
    var user = _authRepository.getUser();
    add(
      UserUpdated(
        userId: user!.uid,
      ),
    );
    print('user g2g');
    print(event.gameId);
    _gameSubcription?.cancel();
    _gameSubcription = _gameRepository.observeGame(event.gameId).listen((game) {
      print('game sub listenting w/ game..');
      // TODO: shouldn't I be passing info on the game in here and not the user (?)
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
    print('game sub g2g');

    _playersSubscription?.cancel();
    _playersSubscription =
        _gameRepository.observePlayers(event.gameId).listen((players) {
      print('observing players...');
      // print('PLAYERS');
      // print(players);
      add(
        PlayersUpdated(
          players: players,
        ),
      );
    });
    print('player sub g2g');

    _downvoteSubscription?.cancel();
    _downvoteSubscription =
        _gameRepository.observeDownvotes(event.gameId).listen((downvotes) {
      print('downvotes..');
      add(
        DownvotesUpdated(
          downvotes: downvotes,
        ),
      );
    });
    print('downvote sub g2g');
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
    // TODO: needed (?)
    if (state.gameStateStatus == GameStateStatus.loading) return;

    emit(
      state.copyWith(
        gameStateStatus: GameStateStatus.loading,
      ),
    );

    try {
      await _gameRepository.waveAtPlayer(
        state.game.id,
        event.playerId,
        event.message,
      );

      print('g2g8');
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
