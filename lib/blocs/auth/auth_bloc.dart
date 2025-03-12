import 'dart:async';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SettingsBloc _settingsBloc;
  final UserBloc _userBloc;
  final UserRepository _userRepository;
  StreamSubscription<GoogleSignInAccount?>? _authUserGoogleSubscription;
  StreamSubscription<auth.User?>? _authUserSubscription;
  StreamSubscription? _userSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required SettingsBloc settingsBloc,
    required UserRepository userRepository,
    required UserBloc userBloc,
  })  : _authRepository = authRepository,
        _settingsBloc = settingsBloc,
        _userBloc = userBloc,
        _userRepository = userRepository,
        super(const AuthState()) {
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthGoogleUserChanged>(_onAuthGoogleUserChanged);
    on<DeleteAccount>(_onDeleteAccount);
    on<LoginWithApple>(_onLoginWithApple);
    on<LoginWithEmailAndPassword>(_onLoginWithEmailAndPassword);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<RegisterAnonymously>(_onRegisterAnonymously);
    on<RegisterWithEmailAndPassword>(_onRegisterWithEmailAndPassword);
    on<ResetError>(_onResetError);
    on<ResetPassword>(_onResetPassword);
    on<SignOut>(_onSignOut);

    _setupAuthSubscriptions();
  }

  void _checkAndEmit(
    Emitter<AuthState> emit,
    AuthStatus status,
  ) {
    // print('check for $status');
    if (state.status == status) return;
    // print('emitting: $status');
    emit(
      state.copyWith(
        status: status,
      ),
    );
  }

  void _clearUserAndReset(
    Emitter<AuthState> emit,
  ) {
    _userBloc.add(
      ClearUser(),
    );
    _userSubscription?.cancel();

    _settingsBloc.add(
      CheckForUser(
        haveUser: false,
      ),
    );

    emit(
      state.initialize().copyWith(
            errorMessage: '',
            status: AuthStatus.unauthenticated,
          ),
    );
  }

  void _setupAuthSubscriptions() {
    _authUserSubscription = _authRepository.user.listen((authUser) {
      // print('auth sub online');
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

            if (state.authUser == null) {
              add(
                AuthUserChanged(
                  authUser: authUser,
                ),
              );

              _settingsBloc.add(
                CheckForUser(
                  haveUser: true,
                ),
              );
            }
          }
        });
      } else if (authUser == null && state.status == AuthStatus.authenticated) {
        print('no auth, but have local cache so Sign Out');
        add(
          SignOut(),
        );
      }
    });

    // Note: only online once the Google workflow commences..
    // Which means we can't use it to initialize SilentSignIn
    _authUserGoogleSubscription =
        _authRepository.userGoogle.listen((googleUser) {
      print('google sub online');
      if (googleUser != null) {
        print('google sub has user');

        add(
          AuthGoogleUserChanged(
            account: googleUser,
          ),
        );
      } else if (googleUser == null &&
          state.status == AuthStatus.authenticated) {
        print('no auth, but have local cache so Sign Out');
        add(
          SignOut(),
        );
      }
    });
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    // print('auth user changed: authenticating');
    emit(
      state.copyWith(
        authUser: event.authUser,
        errorMessage: '',
        status: AuthStatus.authenticated,
        derp: "hasUser",
      ),
    );
  }

  void _onAuthGoogleUserChanged(
    AuthGoogleUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    _checkAndEmit(emit, AuthStatus.submitting);

    try {
      var googleUser = await _authRepository.getGoogleUser(
        account: event.account!,
      );

      if (googleUser != null) {
        emit(
          state.copyWith(
            authUser: googleUser,
            status: AuthStatus.authenticated,
          ),
        );
      } else {
        emit(
          state.initialize().copyWith(
                errorMessage: 'Google validation failed. Please try again.',
                status: AuthStatus.unauthenticated,
              ),
        );
      }
    } catch (err) {
      print('login (google) error: $err');
      emit(
        state.initialize().copyWith(
              errorMessage: err.toString(),
              status: AuthStatus.unauthenticated,
            ),
      );
    }
  }

  void _onDeleteAccount(
    DeleteAccount event,
    Emitter<AuthState> emit,
  ) async {
    _checkAndEmit(emit, AuthStatus.submitting);

    try {
      await _authRepository.deleteAccount();
      _clearUserAndReset(emit);
      // TODO: clear out the games subcollection in the user's RIP'd profile
      // Should be able to do w/ the Delete extension in Firebase
      // Note: there's some wonkiness w/ state, i.e. not seeing Past Games or
      // seeing another account's Past Games, that would be good to clean up.
    } catch (err) {
      print('delete error: $err');
      emit(
        state.initialize().copyWith(
              errorMessage: err.toString(),
              status: AuthStatus.unknown,
            ),
      );
    }
  }

  void _onLoginWithApple(
    LoginWithApple event,
    Emitter<AuthState> emit,
  ) async {
    _checkAndEmit(emit, AuthStatus.submitting);

    try {
      // TODO: finish authorization; see if we can setup a Sub/Stream
      await _authRepository.loginWithApple();
      print('huzzah');
    } catch (err) {
      print('login (apple) error: $err');
      emit(
        state.initialize().copyWith(
              errorMessage: err.toString(),
              status: AuthStatus.unauthenticated,
            ),
      );
    }
  }

  void _onLoginWithEmailAndPassword(
    LoginWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    _checkAndEmit(emit, AuthStatus.submitting);

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
      String errorMessage = err.toString().contains('malformed or has expired')
          ? 'The email and password combination are invalid. Please double check and try again.'
          : err.toString();
      emit(
        state.initialize().copyWith(
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
    _checkAndEmit(emit, AuthStatus.submitting);

    try {
      await _authRepository.loginWithGoogle(
        isSilently: event.isSilent,
        isWeb: event.isWeb,
      );

      emit(
        state.copyWith(
          status: AuthStatus.unknown,
        ),
      );
    } catch (err) {
      print('login (google) error: $err');
      emit(
        state.initialize().copyWith(
              errorMessage: err.toString(),
              status: AuthStatus.unauthenticated,
            ),
      );
    }
  }

  void _onRegisterAnonymously(
    RegisterAnonymously event,
    Emitter<AuthState> emit,
  ) async {
    _checkAndEmit(emit, AuthStatus.submitting);

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
        state.initialize().copyWith(
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
    _checkAndEmit(emit, AuthStatus.submitting);

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
        state.initialize().copyWith(
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
  ) async {
    _checkAndEmit(emit, AuthStatus.submitting);

    try {
      await _authRepository.signOut();
      _clearUserAndReset(emit);
    } catch (err) {
      print('sign out error: $err');
      emit(
        state.initialize().copyWith(
              errorMessage: err.toString(),
              status: AuthStatus.unauthenticated,
            ),
      );
    }
  }

  @override
  Future<void> close() {
    _authUserGoogleSubscription?.cancel();
    _authUserGoogleSubscription = null;
    _authUserSubscription?.cancel();
    _authUserSubscription = null;
    _userSubscription?.cancel();
    _userSubscription = null;
    return super.close();
  }
}
