import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// Hydrated
class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  // final AppPreferences _preferences;
  final AuthRepository _authRepository;
  final DatabaseRepository _databaseRepository;
  final UserBloc _userBloc;
  StreamSubscription<auth.User?>? _authUserSubscription;

  AuthBloc({
    // required AppPreferences preferences,
    required AuthRepository authRepository,
    required DatabaseRepository databaseRepository,
    required UserBloc userBloc,
  })  :
        // _preferences = preferences,
        _authRepository = authRepository,
        _databaseRepository = databaseRepository,
        _userBloc = userBloc,
        super(const AuthState()) {
    on<LoginWithLink>(_onLoginWithLink);
    on<LoginWithEmailAndPassword>(_onLoginWithEmailAndPassword);
    on<RegisterWithEmailAndPassword>(_onRegisterWithEmailAndPassword);
    on<SignOut>(_onSignOut);
    // on<UpdateAuthsUser>(_onUpdateAuthsUser);

    print('auth bloc loaded');
    print(authRepository.getUser());

    _authUserSubscription = _authRepository.user.listen((authUser) {
      print('auth bloc - auth sub');
      if (authUser != null) {
        print('has authUser: $authUser');
      } else {
        print('no auth user');
      }
    });
  }

  void _onLoginWithEmailAndPassword(
    LoginWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.submitting) {
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    try {
      var authUser = await _authRepository.loginWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      var user = await _databaseRepository.getUser(
        userId: authUser!.uid,
      );
      // print('done: authenticated & has user');

      User updatedUser = user.copyWith(
        acceptedTerms: user.acceptedTerms,
        avatarUrl: user.avatarUrl,
        id: user.id,
        name: user.name,
        updatedAt: DateTime.now(),
      );

      _userBloc.add(
        UpdateUser(
          user: updatedUser,
        ),
      );

      emit(
        state.copyWith(
          authUser: authUser,
          status: AuthStatus.authenticated,
          // user: updatedUser,
        ),
      );
    } catch (err) {
      print('login (E&P) error: $err');
      emit(
        state.copyWith(
          authUser: null,
          errorMessage: err.toString(),
          status: AuthStatus.unauthenticated,
          // user: null,
        ),
      );
    }
  }

  void _onLoginWithLink(
    LoginWithLink event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.submitting) {
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    try {
      var authUser = await _authRepository.loginWithEmail(
        email: event.email,
        emailLink: event.emailLink,
      );
      // var user = await _databaseRepository.getUser(
      //   userId: authUser!.uid,
      // );

      emit(
        state.copyWith(
          authUser: authUser,
          status: AuthStatus.authenticated,
          // user: user,
        ),
      );
    } catch (err) {
      print('login (EwL) error: $err');
      emit(
        state.copyWith(
          authUser: null,
          errorMessage: err.toString(),
          status: AuthStatus.unauthenticated,
          // user: null,
        ),
      );
    }
  }

  void _onRegisterWithEmailAndPassword(
    RegisterWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.submitting) {
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    try {
      var authUser = await _authRepository.registerUser(
        email: event.email,
        password: event.password,
      );
      // var user = await _databaseRepository.getUser(
      //   userId: authUser!.uid,
      // );

      emit(
        state.copyWith(
          authUser: authUser,
          status: AuthStatus.authenticated,
          // user: user,
        ),
      );
    } catch (err) {
      print('register error: $err');
      emit(
        state.copyWith(
          authUser: null,
          errorMessage: err.toString(),
          status: AuthStatus.unauthenticated,
          // user: null,
        ),
      );
    }
  }

  void _onSignOut(
    SignOut event,
    Emitter<AuthState> emit,
  ) {
    if (state.status == AuthStatus.submitting) {
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    try {
      _authRepository.signOut();

      _userBloc.add(
        const UpdateUser(
          user: User.emptyUser,
        ),
      );

      emit(
        state.copyWith(
          authUser: null,
          status: AuthStatus.unauthenticated,
          // user: null,
        ),
      );
    } catch (err) {
      print('sign out error: $err');
      emit(
        state.copyWith(
          authUser: null,
          errorMessage: err.toString(),
          status: AuthStatus.unauthenticated,
          // user: null,
        ),
      );
    }
  }

  // void _onUpdateAuthsUser(
  //   UpdateAuthsUser event,
  //   Emitter<AuthState> emit,
  // ) {
  //   emit(
  //     state.copyWith(
  //       user: event.user,
  //     ),
  //   );
  // }

  @override
  Future<void> close() {
    _authUserSubscription?.cancel();
    return super.close();
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    // print('auth bloc hydrated fromJson');
    // print(json);
    return AuthState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    // print('auth bloc hydrated toJson');
    // print(state);
    return state.toJson();
  }
}
