import 'dart:async';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
// import 'package:logger/logger.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GameRepository _gameRepository;
  final UserBloc _userBloc;
  StreamSubscription? _joinedGamesSubscription;

  HomeBloc({
    required GameRepository gameRepository,
    required UserBloc userBloc,
  })  : _gameRepository = gameRepository,
        _userBloc = userBloc,
        super(HomeState.loading()) {
    on<CloseHomeStreams>(_onCloseHomeStreams);
    on<JoinGame>(_onJoinGame);
    on<JoinedGamesUpdated>(_onJoinedGamesUpdated);
    on<LeaveGame>(_onLeaveGame);
    on<RefreshHome>(_onRefreshHome);
    on<UserUpdatedViaHome>(_onUserUpdatedViaHome);

    // TODO: Re-initialize this sub ike we do for GameBloc's subs. On SignOut of
    // Account 1 -> SignIn Account 2 & Account Deletion, this acts wonky.
    // print('setup home bloc');
    _joinedGamesSubscription = _gameRepository
        .observeJoinedGames(_userBloc.state.user)
        .listen((event) {
      add(
        UserUpdatedViaHome(user: _userBloc.state.user),
      );
      add(
        JoinedGamesUpdated(games: event),
      );
    });
  }

  void _onCloseHomeStreams(
    CloseHomeStreams event,
    Emitter<HomeState> emit,
  ) {
    _joinedGamesSubscription?.cancel();
  }

  void _onJoinGame(
    JoinGame event,
    Emitter<HomeState> emit,
  ) async {
    print('trying to join game in bloc');
    try {
      emit(
        state.copyWith(
          joiningGame: event.gameCode,
          isLoading: true,
        ),
      );

      var game = await _gameRepository.joinGame(
        '', // Firebase Id
        event.gameCode, // 5-digit
        _userBloc.state.user,
      );

      emit(
        state.copyWith(
          isLoading: false,
          joinedGame: game,
          joiningGame: '',
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          error: '$err',
          isLoading: false,
          joiningGame: '',
        ),
      );
    }
  }

  void _onJoinedGamesUpdated(
    JoinedGamesUpdated event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        games: event.games..sort((a, b) => b.joinedAt!.compareTo(a.joinedAt!)),
      ),
    );
  }

  void _onLeaveGame(
    LeaveGame event,
    Emitter<HomeState> emit,
  ) async {
    // TODO: leaving and joining the same game multiple times causes an issue
    // Something w/ the subscription I believe.
    try {
      emit(
        state.copyWith(
          games: state.games..remove(event.game),
          leavingGame: event.game,
        ),
      );

      await _gameRepository.leaveGame(
        _userBloc.state.user,
        event.game,
      );

      emit(
        state.copyWith(
          leavingGame: null,
          // leavingGame: UserGame.emptyUserGame, // Note: not this
        ),
      );
    } catch (err) {
      print('home bloc: leave game err: $err');
      emit(
        state.copyWith(
          leavingGame: null,
          // leavingGame: UserGame.emptyUserGame, // Note: not this
        ),
      );
    }
  }

  void _onRefreshHome(
    RefreshHome event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        error: '',
        joinedGame: Game.emptyGame,
        joiningGame: '',
        leavingGame: UserGame.emptyUserGame,
        isLoading: false,
      ),
    );
  }

  void _onUserUpdatedViaHome(
    UserUpdatedViaHome event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        isLoading: false,
        user: event.user,
      ),
    );
  }

  @override
  Future<void> close() {
    _joinedGamesSubscription?.cancel();
    _joinedGamesSubscription = null;
    return super.close();
  }
}
