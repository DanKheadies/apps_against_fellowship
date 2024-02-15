import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:kt_dart/kt.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';

part 'create_game_event.dart';
part 'create_game_state.dart';

class CreateGameBloc extends Bloc<CreateGameEvent, CreateGameState> {
  final CardsRepository _cardsRepository;
  final GameRepository _gameRepository;
  final UserBloc _userBloc;

  CreateGameBloc({
    required CardsRepository cardsRepository,
    required GameRepository gameRepository,
    required UserBloc userBloc,
  })  : _cardsRepository = cardsRepository,
        _gameRepository = gameRepository,
        _userBloc = userBloc,
        //  super(const CreateGameState()) {
        super(CreateGameState.empty()) {
    on<CardSetSelected>(_onCardSetSelected);
    on<CardSourceSelected>(_onCardSourceSelected);
    on<ChangeDraw2Pick3Enabled>(_onChangeDraw2Pick3Enabled);
    on<ChangePick2Enabled>(_onChangePick2Enabled);
    on<ChangePlayerLimit>(_onChangePlayerLimit);
    on<ChangePrizesToWin>(_onChangePrizesToWin);
    on<CreateGame>(_onCreateGame);
    on<LoadCreateGame>(_onLoadCreateGame);
  }

  void _onCardSetSelected(
    CardSetSelected event,
    Emitter<CreateGameState> emit,
  ) {
    if (state.selectedSets.contains(event.cardSet)) {
      emit(
        state.copyWith(
          selectedSets: state.selectedSets.minusElement(event.cardSet).toSet(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          selectedSets: state.selectedSets.plusElement(event.cardSet).toSet(),
        ),
      );
    }
  }

  void _onCardSourceSelected(
    CardSourceSelected event,
    Emitter<CreateGameState> emit,
  ) {
    if (!event.isAllChecked) {
      emit(
        state.copyWith(
          selectedSets: state.selectedSets
              .plus(state.cardSets.filter((cs) => cs.source == event.source))
              .toSet(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          selectedSets: state.selectedSets
              .filter((s) => s.source != event.source)
              .toSet(),
        ),
      );
    }
  }

  void _onChangeDraw2Pick3Enabled(
    ChangeDraw2Pick3Enabled event,
    Emitter<CreateGameState> emit,
  ) {
    emit(
      state.copyWith(
        draw2pick3Enabled: event.enabled,
      ),
    );
  }

  void _onChangePick2Enabled(
    ChangePick2Enabled event,
    Emitter<CreateGameState> emit,
  ) {
    emit(
      state.copyWith(
        pick2Enabled: event.enabled,
      ),
    );
  }

  void _onChangePlayerLimit(
    ChangePlayerLimit event,
    Emitter<CreateGameState> emit,
  ) {
    _userBloc.add(
      UpdateUser(
        user: _userBloc.state.user.copyWith(
          playerLimit: event.playerLimit,
        ),
      ),
    );

    emit(
      state.copyWith(
        playerLimit: event.playerLimit,
      ),
    );
  }

  void _onChangePrizesToWin(
    ChangePrizesToWin event,
    Emitter<CreateGameState> emit,
  ) {
    _userBloc.add(
      UpdateUser(
        user: _userBloc.state.user.copyWith(
          prizesToWin: event.prizesToWin,
        ),
      ),
    );

    emit(
      state.copyWith(
        prizesToWin: event.prizesToWin,
      ),
    );
  }

  void _onCreateGame(
    CreateGame event,
    Emitter<CreateGameState> emit,
  ) async {
    if (state.createGameStatus == CreateGameStatus.loading) return;

    emit(
      state.copyWith(
        createGameStatus: CreateGameStatus.loading,
        error: null,
      ),
    );

    try {
      var game = await _gameRepository.createGame(
        _userBloc.state.user,
        state.selectedSets,
        prizesToWin: state.prizesToWin,
        playerLimit: state.playerLimit,
        pick2Enabled: state.pick2Enabled,
        draw2Pick3Enabled: state.draw2pick3Enabled,
      );

      emit(
        state.copyWith(
          createdGame: game,
          createGameStatus: CreateGameStatus.loaded,
        ),
      );
    } catch (err) {
      print('Create Game Error: $err');
      emit(
        state.copyWith(
          createGameStatus: CreateGameStatus.error,
          error: '$err',
        ),
      );
    }
  }

  void _onLoadCreateGame(
    LoadCreateGame event,
    Emitter<CreateGameState> emit,
  ) async {
    if (state.createGameStatus == CreateGameStatus.loaded) return;
    print('test');

    try {
      var cardSets = await _cardsRepository.getAvailableCardSets();
      var filteredCardSets = cardSets.where((cs) {
        return (cs.source == "Developer" &&
                _userBloc.state.user.developerPackEnabled) ||
            cs.source != "Developer";
      }).toList();

      emit(
        state.copyWith(
          cardSets: filteredCardSets.toImmutableList(),
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          createGameStatus: CreateGameStatus.error,
          error: err.toString(),
        ),
      );
    }
  }
}
