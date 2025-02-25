import 'dart:async';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserBloc _userBloc;
  final UserRepository _userRepository;
  StreamSubscription<auth.User?>? _authUserSubscription;
  StreamSubscription? _userSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required UserBloc userBloc,
  })  : _authRepository = authRepository,
        _userBloc = userBloc,
        _userRepository = userRepository,
        super(const AuthState()) {
    on<AuthUserChanged>(_onAuthUserChanged);
    // on<LoginWithApple>(_onLoginWithApple); // TODO: https://pub.dev/packages/sign_in_with_apple
    on<LoginWithLink>(_onLoginWithLink);
    on<LoginWithEmailAndPassword>(_onLoginWithEmailAndPassword);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<LoginWithGoogleSilently>(_onLoginWithGoogleSilently);
    on<RegisterAnonymously>(_onRegisterAnonymously);
    on<RegisterWithEmailAndPassword>(_onRegisterWithEmailAndPassword);
    on<ResetError>(_onResetError);
    on<ResetPassword>(_onResetPassword);
    on<SignOut>(_onSignOut);

    _setupAuthSubscriptions();
  }

  void _setupAuthSubscriptions() {
    _authUserSubscription = _authRepository.user.listen((authUser) {
      // print('auth sub');
      if (authUser != null) {
        // print('auth sub has user');

        _userSubscription =
            _userRepository.getUserStream(userId: authUser.uid).listen((user) {
          // Wait for an id from the stream before carrying on.
          if (user != null) {
            _userBloc.add(
              UpdateUser(
                updateFirebase: false,
                user: user,
              ),
            );

            add(
              AuthUserChanged(
                authUser: authUser,
              ),
            );
          }
        });
      }
    });
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        authUser: event.authUser,
        errorMessage: '',
        lastUpdate: DateTime.now(),
        status: AuthStatus.authenticated,
      ),
    );
  }

  void _onLoginWithEmailAndPassword(
    LoginWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.submitting) return;

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

      var user = await _userRepository.getUser(
        userId: authUser!.uid,
      );

      User updatedUser = user.copyWith(
        updatedAt: DateTime.now(),
      );

      _userBloc.add(
        UpdateUser(
          updateFirebase: true,
          user: updatedUser,
        ),
      );

      emit(
        state.copyWith(
          authUser: authUser,
          status: AuthStatus.authenticated,
        ),
      );
    } catch (err) {
      print('login (E&P) error: $err');
      // TODO: provide a better errorMessage
      String errorMessage = err.toString().contains('malformed or has expired')
          ? 'The email and password combination are invalid. Please double check and try again.'
          : err.toString();
      emit(
        state.copyWith(
          authUser: null,
          errorMessage: errorMessage,
          status: AuthStatus.unauthenticated,
        ),
      );
    }
  }

  void _onLoginWithGoogle(
    LoginWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.submitting) return;

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    try {
      var googleUser = await _authRepository.loginWithGoogle();

      emit(
        state.copyWith(
          authUser: googleUser,
          lastUpdate: DateTime.now(),
          status: AuthStatus.authenticated,
        ),
      );
    } catch (err) {
      print('login (google) error: $err');
      emit(
        state.copyWith(
          authUser: null,
          errorMessage: err.toString(),
          status: AuthStatus.unauthenticated,
        ),
      );
    }
  }

  void _onLoginWithGoogleSilently(
    LoginWithGoogleSilently event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.submitting) return;

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    try {
      await _authRepository.loginWithGoogleSilently();

      emit(
        state.copyWith(
          lastUpdate: DateTime.now(),
          status: AuthStatus.authenticated,
        ),
      );
    } catch (err) {
      print('login (google) error: $err');
      emit(
        state.copyWith(
          authUser: null,
          errorMessage: err.toString(),
          status: AuthStatus.unauthenticated,
        ),
      );
    }
  }

  void _onLoginWithLink(
    LoginWithLink event,
    Emitter<AuthState> emit,
  ) async {
    print('TODO: login w/ link');
    // if (state.status == AuthStatus.submitting) return;

    // emit(
    //   state.copyWith(
    //     status: AuthStatus.submitting,
    //   ),
    // );

    // try {
    //   var authUser = await _authRepository.loginWithEmail(
    //     email: event.email,
    //     emailLink: event.emailLink,
    //   );

    //   emit(
    //     state.copyWith(
    //       authUser: authUser,
    //       status: AuthStatus.authenticated,
    //     ),
    //   );
    // } catch (err) {
    //   print('login (EwL) error: $err');
    //   emit(
    //     state.copyWith(
    //       authUser: null,
    //       errorMessage: err.toString(),
    //       status: AuthStatus.unauthenticated,
    //     ),
    //   );
    // }
  }

  void _onRegisterAnonymously(
    RegisterAnonymously event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.submitting) return;

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    try {
      var anonUser = await _authRepository.registerAnonymous();

      emit(
        state.copyWith(
          authUser: anonUser,
          status: AuthStatus.authenticated,
        ),
      );
    } catch (err) {
      print('register anon error: $err');
      emit(
        state.copyWith(
          authUser: null,
          errorMessage: err.toString(),
          status: AuthStatus.unauthenticated,
        ),
      );
    }
  }

  void _onRegisterWithEmailAndPassword(
    RegisterWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.submitting) return;

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    try {
      var authUser = await _authRepository.registerUserWithFirebase(
        email: event.email,
        password: event.password,
      );

      _userBloc.add(
        UpdateUser(
          accountCreation: true,
          updateFirebase: true,
          user: User.emptyUser.copyWith(
            email: event.email,
            name: event.name,
            id: authUser?.uid,
            updatedAt: authUser?.metadata.creationTime,
          ),
        ),
      );

      emit(
        state.copyWith(
          authUser: authUser,
          status: AuthStatus.authenticated,
        ),
      );
    } catch (err) {
      print('register error: $err');
      emit(
        state.copyWith(
          authUser: null,
          errorMessage: err.toString(),
          status: AuthStatus.unauthenticated,
        ),
      );
    }
  }

  void _onResetError(
    ResetError event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        errorMessage: '',
      ),
    );
  }

  void _onResetPassword(
    ResetPassword event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        errorMessage: '',
      ),
    );
  }

  void _onSignOut(
    SignOut event,
    Emitter<AuthState> emit,
  ) {
    if (state.status == AuthStatus.submitting) return;

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    try {
      _authRepository.signOut();

      _userBloc.add(
        ClearUser(),
      );
      _userSubscription?.cancel();
      _userSubscription = null;

      emit(
        state.copyWith(
          authUser: null,
          status: AuthStatus.unauthenticated,
        ),
      );
    } catch (err) {
      print('sign out error: $err');
      emit(
        state.copyWith(
          authUser: null,
          errorMessage: err.toString(),
          status: AuthStatus.unauthenticated,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _authUserSubscription?.cancel();
    _authUserSubscription = null;
    _userSubscription?.cancel();
    _userSubscription = null;
    return super.close();
  }

  // @override
  // AuthState? fromJson(Map<String, dynamic> json) {
  //   return AuthState.fromJson(json);
  // }

  // @override
  // Map<String, dynamic>? toJson(AuthState state) {
  //   return state.toJson();
  // }
}
