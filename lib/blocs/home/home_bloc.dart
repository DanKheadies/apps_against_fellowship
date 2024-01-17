import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';

import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // final GameRepository _gameRepository;
  final UserRepository _userRepository;
  StreamSubscription? _joinedGamesSubscription;
  StreamSubscription? _userSubscription;

  HomeBloc({
    // required GameRepository gameRepository,
    required UserRepository userRepository,
  })  :
        // _gameRepository = gameRepository,
        _userRepository = userRepository,
        super(HomeState.loading()) {
    on<HomeStarted>(_onHomeStarted);
    on<JoinedGamesUpdated>(_onJoinedGamesUpdated);
    on<UserUpdatedViaHome>(_onUserUpdatedViaHome);
    on<LeaveGame>(_onLeaveGame);
    on<JoinGame>(_onJoinGame);

    print('home bloc g2g');
  }

  void _onHomeStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // _userSubscription?.cancel();
      // _userSubscription = _userRepository.getUserStream().listen((user)) {
      //  ... do the user stream stuff
      //  add(
      //    UserUpdated(user);
      //  );
      // }
    } catch (err) {
      Logger().e('Error on home start: $err');
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

  void _onLeaveGame(
    LeaveGame event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          games: state.games..remove(event.game),
          leavingGame: event.game,
        ),
      );
      // TODO
      // await _gameRepository.leaveGame(event.game);
      emit(
        state.copyWith(
          leavingGame: null,
        ),
      );
    } catch (err) {
      print('home bloc: leave game err: $err');
      emit(
        state.copyWith(
          leavingGame: null,
        ),
      );
    }
  }

  void _onJoinGame(
    JoinGame event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          joiningGame: event.gameCode,
        ),
      );
      // TODO
      // var game = await _gameRepository.joinGame(event.gameCode);
      emit(
        state.copyWith(
          // joinedGame: game,
          joiningGame: null,
        ),
      );
    } catch (err) {
      print('home bloc: err joining game: $err');
      emit(
        state.copyWith(
          error: '$err',
          // joinedGame: null,
          joiningGame: null,
        ),
      );
    }
  }
}
