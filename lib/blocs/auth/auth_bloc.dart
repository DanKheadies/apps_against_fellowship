import 'dart:async';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
// import 'package:flutter/foundation.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserBloc _userBloc;
  final UserRepository _userRepository;
  StreamSubscription<auth.User?>? _authUserSubscription;
  // StreamSubscription<GoogleSignInAccount?>? _authGoogleUserSubscription;
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
    // on<AuthGoogleUserChanged>(_onAuthGoogleUserChanged);
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
      print('auth sub');
      if (authUser != null) {
        print('auth sub has user');
        print(authUser);
        add(
          AuthUserChanged(
            authUser: authUser,
          ),
        );

        _setupUserSubscription(authUser.uid);
        // _userSubscription =
        //     _userRepository.getUserStream(userId: authUser.uid).listen((user) {
        //   _userBloc.add(
        //     UpdateUser(
        //       updateFirebase: false,
        //       user: user,
        //     ),
        //   );
        // });
      }
    });

    // Update: I think this is overkill now that I've setup the Google-Firebase
    // auth connection.
    // TODO: incorporate the scopes for web elsewheres
    // _authGoogleUserSubscription =
    //     _authRepository.userGoogle.listen((account) async {
    //   print('google sub');
    //   if (account != null && kIsWeb) {
    //     print('google sub has user for web');
    //     // await _googleSignIn.canAccessScopes(scopes);
    //     bool continueWithSetup =
    //         await _authRepository.authorizeGoogleScopesForWeb(
    //       account: account,
    //     );

    //     if (continueWithSetup) {
    //       AuthGoogleUserChanged(
    //         authGoogleUser: account,
    //       );
    //     } else {
    //       print('Google account (for web) changed but didn\'t pass scopes.');
    //     }
    //   } else if (account != null && !kIsWeb) {
    //     print('google sub has user');
    //     // TODO: may need to throw the web case before this and check scopes
    //     // before saying "authenticated"
    //     AuthGoogleUserChanged(
    //       authGoogleUser: account,
    //     );

    //     _setupUserSubscription(account.id);
    //     // _userSubscription =
    //     //     _userRepository.getUserStream(userId: account.id).listen((user) {
    //     //   _userBloc.add(
    //     //     UpdateUser(
    //     //       updateFirebase: false,
    //     //       user: user,
    //     //     ),
    //     //   );
    //     // });
    //   }
    // });
  }

  void _setupUserSubscription(String id) {
    print('setting up user sub w/ id: $id');
    _userSubscription =
        _userRepository.getUserStream(userId: id).listen((user) {
      print('updating user: ${user.name}');
      _userBloc.add(
        UpdateUser(
          updateFirebase: false,
          user: user,
        ),
      );
    });
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    print('Auth User Changed');
    emit(
      state.copyWith(
        authUser: event.authUser,
        errorMessage: '',
        lastUpdate: DateTime.now(),
        status: AuthStatus.authenticated,
      ),
    );
  }

  // void _onAuthGoogleUserChanged(
  //   AuthGoogleUserChanged event,
  //   Emitter<AuthState> emit,
  // ) {
  //   // TODO (?)
  //   // if (kIsWeb && account != null) {
  //   //     print('for web..');
  //   //     isAuthorized = await _googleSignIn.canAccessScopes(scopes);
  //   //     print('isAuthorized: $isAuthorized');
  //   //   }
  //   emit(
  //     state.copyWith(
  //       authGoogleUser: event.authGoogleUser,
  //       errorMessage: '',
  //       status: AuthStatus.authenticated,
  //     ),
  //   );
  // }

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
      // TODO: do I even need to do this?
      // Technically, I should be handling the "getUser" via the stream / sub
      // This will update Firebase & their account
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
          authGoogleUser: googleUser,
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
    print('TODO: login w/ google');
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
    print('register w/ email pass');
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
      print('registered:');
      print(authUser?.uid);
      print(event.email);
      print(event.name);
      print('adding to userBloc');

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
    // _authGoogleUserSubscription?.cancel();
    // _authGoogleUserSubscription = null;
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
