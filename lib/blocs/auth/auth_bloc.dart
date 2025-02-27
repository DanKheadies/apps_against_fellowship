import 'dart:async';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserBloc _userBloc;
  final UserRepository _userRepository;
  StreamSubscription<GoogleSignInAccount?>? _authUserGoogleSubscription;
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
    on<AuthGoogleUserChanged>(_onAuthGoogleUserChanged);
    // on<LoginWithApple>(_onLoginWithApple); // TODO: https://pub.dev/packages/sign_in_with_apple
    on<LoginWithLink>(_onLoginWithLink);
    on<LoginWithEmailAndPassword>(_onLoginWithEmailAndPassword);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    // on<LoginWithGoogleSilently>(_onLoginWithGoogleSilently);
    on<RegisterAnonymously>(_onRegisterAnonymously);
    on<RegisterWithEmailAndPassword>(_onRegisterWithEmailAndPassword);
    on<ResetError>(_onResetError);
    on<ResetPassword>(_onResetPassword);
    on<SignOut>(_onSignOut);

    _setupAuthSubscriptions();
  }

  void _setupAuthSubscriptions() {
    _authUserSubscription = _authRepository.user.listen((authUser) {
      print('auth sub online');
      if (authUser != null) {
        print('auth sub has user');

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
      } else if (authUser == null && state.status == AuthStatus.authenticated) {
        print('no auth, but have local cache so Sign Out');
        add(
          SignOut(),
        );
      } else {
        // Note: not the right workflow to include here; should be in own
        // Google Sub
        // print('don\'t have authUser, so lets check google silently');
        // if (!kIsWeb) {
        //   add(
        //     LoginWithGoogle(isSilent: true),
        //   );
        // }
      }
    });

    // Note: online online once the Google workflow commences..
    _authUserGoogleSubscription =
        _authRepository.userGoogle.listen((googleUser) {
      print('google sub online');
      if (googleUser != null) {
        print('google sub has user');

        // TODO: get auth.User? from googleUser
        add(
          AuthGoogleUserChanged(
            account: googleUser,
          ),
        );

        // var authUser = await _authRepository.loginWithGoogle(
        //     isSilently: kIsWeb ? false : true);

        // _userSubscription =
        //     _userRepository.getUserStream(userId: googleUser.id).listen((user) {
        //   // Wait for an id from the stream before carrying on.
        //   if (user != null) {
        //     _userBloc.add(
        //       UpdateUser(
        //         updateFirebase: false,
        //         user: user,
        //       ),
        //     );

        //     add(
        //       AuthUserChanged(
        //         authUser: authUser,
        //       ),
        //     );
        //   }
        // });
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
    print('auth user changed: authenticating');
    print('prev lastUpdate: ${state.lastUpdate}');
    print('curr lastUpdate: ${DateTime.now()}');
    emit(
      state.copyWith(
        authUser: event.authUser,
        errorMessage: '',
        lastUpdate: DateTime.now(),
        status: AuthStatus.authenticated,
      ),
    );
  }

  void _onAuthGoogleUserChanged(
    AuthGoogleUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.submitting) return;

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    try {
      // var googleUser = await _authRepository.loginWithGoogle(
      //   isSilently: event.isSilent,
      // );
      var googleUser = await _authRepository.getGoogleUser(
        account: event.account!,
      );

      if (googleUser != null) {
        emit(
          state.copyWith(
            authUser: googleUser,
            lastUpdate: DateTime.now(),
            status: AuthStatus.authenticated,
          ),
        );
      } else {
        emit(
          state.copyWith(
            authUser: null,
            errorMessage: 'Google validation failed. Please try again.',
            // errorMessage: '',
            status: AuthStatus.unauthenticated,
          ),
        );
      }
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
    print('login w/ email pass');

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
    print('login w/ google');
    if (event.isSilent) {
      print('SILENTLY...');
    }

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    try {
      // var googleUser = await _authRepository.loginWithGoogle(
      //   isSilently: event.isSilent,
      // );
      await _authRepository.loginWithGoogle(
        isSilently: event.isSilent,
      );

      // if (googleUser != null) {
      //   emit(
      //     state.copyWith(
      //       authUser: googleUser,
      //       lastUpdate: DateTime.now(),
      //       status: AuthStatus.authenticated,
      //     ),
      //   );
      // } else {
      //   emit(
      //     state.copyWith(
      //       authUser: null,
      //       // errorMessage: event.isSilent
      //       //     ? 'Google validation failed. Please try again.'
      //       //     : '',
      //       errorMessage: '',
      //       status: AuthStatus.unauthenticated,
      //     ),
      //   );
      // }
      emit(
        state.copyWith(
          status: AuthStatus.unknown,
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

  // void _onLoginWithGoogleSilently(
  //   LoginWithGoogleSilently event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   if (state.status == AuthStatus.submitting) return;
  //   print('login w/ google silently');

  //   emit(
  //     state.copyWith(
  //       status: AuthStatus.submitting,
  //     ),
  //   );

  //   try {
  //     // await _authRepository.loginWithGoogleSilently();
  //     var googleUser = await _authRepository.loginWithGoogle(isSilently: true);

  //     emit(
  //       state.copyWith(
  //         authUser: googleUser,
  //         lastUpdate: DateTime.now(),
  //         status: AuthStatus.authenticated,
  //       ),
  //     );
  //   } catch (err) {
  //     print('login (google) error: $err');
  //     emit(
  //       state.copyWith(
  //         authUser: null,
  //         errorMessage: err.toString(),
  //         status: AuthStatus.unauthenticated,
  //       ),
  //     );
  //   }
  // }

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
  ) async {
    if (state.status == AuthStatus.submitting) return;

    emit(
      state.copyWith(
        status: AuthStatus.submitting,
      ),
    );

    try {
      print('trying to sign out');
      await _authRepository.signOut();
      print('done awaiting sign out');

      _userBloc.add(
        ClearUser(),
      );
      _userSubscription?.cancel();
      _userSubscription = null;
      print('user should be signed out via auth');
      emit(
        state.copyWith(
          authUser: null,
          errorMessage: '',
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
    _authUserGoogleSubscription?.cancel();
    _authUserGoogleSubscription = null;
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
