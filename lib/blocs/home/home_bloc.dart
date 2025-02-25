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
    on<JoinGame>(_onJoinGame);
    on<JoinedGamesUpdated>(_onJoinedGamesUpdated);
    on<LeaveGame>(_onLeaveGame);
    on<RefreshHome>(_onRefreshHome);
    on<UserUpdatedViaHome>(_onUserUpdatedViaHome);

    _joinedGamesSubscription = _gameRepository
        .observeJoinedGames(_userBloc.state.user)
        .listen((event) {
      print('observing / listening..');
      add(
        UserUpdatedViaHome(user: _userBloc.state.user),
      );
      add(
        JoinedGamesUpdated(games: event),
      );
    });
  }

  // void _onHomeStarted(
  //   HomeStarted event,
  //   Emitter<HomeState> emit,
  // ) async {
  //   // TODO: see if a user sub and joinedGame sub are necessary
  //   try {
  //     _userSubscription?.cancel();
  //     _userSubscription = _userRepository.
  //   } catch (err) {
  //     Logger().e('Error on home start: $err');
  //   }
  // }

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

      // await Future.delayed(const Duration(seconds: 3));

      emit(
        state.copyWith(
          isLoading: false,
          joinedGame: game,
          joiningGame: '',
        ),
      );

      // emit(
      //   state.copyWith(
      //     error: 'and theres an error: $derp',
      //     isLoading: false,
      //     // joinedGame: null,
      //     joiningGame: '',
      //   ),
      // );
    } catch (err) {
      print('home bloc: err joining game: $err');
      emit(
        state.copyWith(
          error: '$err',
          isLoading: false,
          // joinedGame: null,
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
    try {
      print('trying to leave game');
      emit(
        state.copyWith(
          isLoading: true,
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
          isLoading: false,
          leavingGame: null,
        ),
      );
    } catch (err) {
      print('home bloc: leave game err: $err');
      emit(
        state.copyWith(
          isLoading: false,
          leavingGame: null,
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
        joinedGame: null,
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
