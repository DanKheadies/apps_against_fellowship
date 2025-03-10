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
    // on<LoginWithApple>(_onLoginWithApple); // TODO: https://pub.dev/packages/sign_in_with_apple
    on<LoginWithLink>(_onLoginWithLink);
    on<LoginWithEmailAndPassword>(_onLoginWithEmailAndPassword);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<RegisterAnonymously>(_onRegisterAnonymously);
    on<RegisterWithEmailAndPassword>(_onRegisterWithEmailAndPassword);
    on<ResetError>(_onResetError);
    on<ResetPassword>(_onResetPassword);
    on<SignOut>(_onSignOut);

    _setupAuthSubscriptions();
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

            // TODO: call settings and intialize audio
            // _userBloc.
            // _settingsBloc.
            // Note: don't want to have to add settingsBloc as a requirement here
            // but can.
            // Only want to do this once, i.e. stick up with auth check above.
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
    if (state.status == AuthStatus.submitting) return;
    print('auth google user changed: authenticating');

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

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
    if (state.status == AuthStatus.submitting) return;
    print('login w/ google');
    if (event.isSilent) {
      print('SILENTLY...');
    }

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    // TODO: handle kIsWeb
    // if (!kIsWeb) {
    //   add(
    //     LoginWithGoogle(isSilent: true),
    //   );
    // }
    // Not sure where tho..
    try {
      await _authRepository.loginWithGoogle(
        isSilently: event.isSilent,
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
    if (state.status == AuthStatus.submitting) return;

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    try {
      await _authRepository.signOut();

      _userBloc.add(
        ClearUser(),
      );
      _userSubscription?.cancel();
      _userSubscription = null;

      _settingsBloc.add(
        CheckForUser(
          haveUser: false,
        ),
      );

      // TODO: close out the HomeBloc's stream
      // Might be able to do it via the Sign Out button
      // Yup, that did it. Should make sure all sign out options include closing
      // the Home Sub/Stream, but I could bake it into this SignOut handler.
      // _homeBloc.close();

      emit(
        state.initialize().copyWith(
              errorMessage: '',
              status: AuthStatus.unauthenticated,
            ),
      );
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
