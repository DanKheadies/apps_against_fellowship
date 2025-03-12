import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepository {
  final auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserRepository _userRepository;

  AuthRepository({
    auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    required UserRepository userRepository,
  })  : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email'],
            ),
        _userRepository = userRepository;

  /// Get Firebase's current user.
  auth.User? getUser() {
    try {
      final currentUser = _firebaseAuth.currentUser;
      return currentUser;
    } catch (err) {
      print('get user err: $err');
      throw Exception(err);
    }
  }

  /// A stream for Firebase's user changes.
  Stream<auth.User?> get user => _firebaseAuth.userChanges();

  /// A stream for Google's user changes.
  Stream<GoogleSignInAccount?> get userGoogle =>
      _googleSignIn.onCurrentUserChanged;

  Future<void> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser!.delete();
      print('RIP');
    } on auth.FirebaseAuthException catch (e) {
      print(e);
      // TODO: (?)
      // if (e.code == 'requires-recent-login') {
      //   try {
      //     final providerData = _firebaseAuth.currentUser?.providerData.first;

      //     // if (AppleAuthProvider().providerId == providerData!.providerId) {
      //     //   await firebaseAuth.currentUser!
      //     //       .reauthenticateWithProvider(AppleAuthProvider());
      //     // } else
      //     // if (GoogleAuthProvider().providerId ==
      //     //     providerData.providerId) {
      //     //   await firebaseAuth.currentUser!
      //     //       .reauthenticateWithProvider(GoogleAuthProvider());
      //     // }
      //     // if (_googleSignIn.clientId ==
      //     //     providerData?.providerId) {
      //     //   await _firebaseAuth.currentUser!
      //     //       .reauthenticateWithProvider(_googleSignIn.signIn());
      //     // }

      //     await _firebaseAuth.currentUser?.delete();
      //   } catch (e) {
      //     // Handle exceptions
      //   }
      // } else {
      //   print('firebase auth exception - not recent login');
      //   print(e);
      // }
    } catch (err) {
      print('delete error: $err');
      throw Exception(err);
    }
  }

  // /// Authenticate with Google's web access.
  // Future<bool> authorizeGoogleScopesForWeb({
  //   required GoogleSignInAccount account,
  // }) async {
  //   try {
  //     return await _googleSignIn.requestScopes(['email']);
  //   } catch (err) {
  //     print('google error: $err');
  //     throw Exception(err);
  //   }
  // }

  /// Authenticate with Apple credentials through an OAuth route.
  // TODO: issue w/ adding the Sign In with Apple capability in Runner & Developer
  Future<void> loginWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // webAuthenticationOptions: WebAuthenticationOptions(
        //   clientId: clientId,
        //   redirectUri: redirectUri,
        // ),
      );

      print(appleCredential);
      // auth.UserCredential appleUser = await _firebaseAuth.
      // _firebaseAuth.signInWithCredential(credential);
      final oAuthCredential = auth.OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      auth.UserCredential credentials =
          await _firebaseAuth.signInWithCredential(oAuthCredential);
      print('has creds');
      print(credentials);
    } catch (err) {
      print('apple err: $err');
      throw Exception(err);
    }
  }

  /// Authenticate with Google's service.
  Future<void> loginWithGoogle({
    required bool isSilently,
    required bool isWeb,
  }) async {
    try {
      // UPDATE: Google on Web is a bit of an issue; we're not even getting to
      // this point in the Bloc/Repo flow because it has to use a web-specific
      // button from google sign in. We'll then have to figure out some way to
      // incorporate this workflow to maintain the consistent access, etc.
      // Going to leave but ignore for now.

      // if (kIsWeb) {
      //   print('google sub has user for web');
      //   GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      //   if (account != null) {
      //     print('has account');
      //     bool continueWithSetup = await authorizeGoogleScopesForWeb(
      //       account: account,
      //     );

      //     if (!continueWithSetup) {
      //       print('Google account (for web) changed but didn\'t pass scopes.');
      //       return null;
      //     }
      //   }
      // }
      // late GoogleSignInAccount? account;
      if (isSilently) {
        // account = await _googleSignIn.signInSilently();
        await _googleSignIn.signInSilently();
      } else if (isWeb) {
        // TODO: finish; incorporating the Web button allows for the next step,
        // but we're still missing some authorization stuffs.. Also, having the
        // web package active causes iOS not to build correctly, so FML.
        print('isWeb: ${_googleSignIn.scopes}');
        // await _googleSignIn.canAccessScopes(_googleSignIn.scopes);
        final bool isAuthorized =
            await _googleSignIn.requestScopes(_googleSignIn.scopes);
        print(isAuthorized);
      } else {
        // account = await _googleSignIn.signIn();
        await _googleSignIn.signIn();
      }
      // print('contining w/ the info..');
      // print(account);
    } catch (err) {
      print('google err: $err');
      throw Exception(err);
    }
  }

  /// Authenticate with Google's service.
  Future<auth.User?> getGoogleUser({
    required GoogleSignInAccount account,
  }) async {
    try {
      GoogleSignInAuthentication? googleAuth = await account.authentication;

      auth.OAuthCredential googleCredentials =
          auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      auth.UserCredential googleUser =
          await _firebaseAuth.signInWithCredential(googleCredentials);

      // If successful, check if the user already exists; otherwise, create a
      // user.
      if (googleUser.user != null) {
        bool exists = await _userRepository.checkForUser(
          userId: googleUser.user!.uid,
        );

        if (!exists) {
          await _userRepository.createUser(
            user: User.emptyUser.copyWith(
              id: googleUser.user?.uid,
              name: googleUser.user?.displayName,
              email: googleUser.user?.email,
              avatarUrl: account.photoUrl,
              updatedAt: DateTime.now(),
            ),
          );
        }
      }

      return googleUser.user;
    } catch (err) {
      print('google err: $err');
      throw Exception(err);
    }
  }

  /// Authenticate with Firebase's email-password.
  Future<auth.User?> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredentials.user;
    } catch (err) {
      print('login error: $err');
      throw Exception(err);
    }
  }

  /// Authenticate with Firebase anonymously.
  Future<auth.User?> registerAnonymous() async {
    try {
      final anonCredentials = await _firebaseAuth.signInAnonymously();

      await _userRepository.createUser(
        user: User.emptyUser.copyWith(
          id: anonCredentials.user!.uid,
          name: 'Anon Emus',
          updatedAt: anonCredentials.user!.metadata.creationTime,
        ),
      );

      return anonCredentials.user;
    } catch (err) {
      print('register anon err: $err');
      throw Exception(err);
    }
  }

  /// Create a user account on Firebase with email and password.
  Future<auth.User?> registerUserWithFirebase({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final userCredentials =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _userRepository.createUser(
        user: User.emptyUser.copyWith(
          id: userCredentials.user!.uid,
          name: name ?? '',
          updatedAt: userCredentials.user!.metadata.creationTime,
        ),
      );

      return userCredentials.user;
    } catch (err) {
      print('register user err: $err');
      throw Exception(err);
    }
  }

  /// Send a Firebase auth password reset.
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email,
      );
    } catch (err) {
      throw Exception(err);
    }
  }

  // /// Authenticate with Firebase's email link. (TODO)
  // Future<auth.User?> loginWithEmail({
  //   required String email,
  //   required String emailLink,
  // }) async {
  //   try {
  //     final userCredentials = await _firebaseAuth.signInWithEmailLink(
  //       email: email,
  //       emailLink: emailLink,
  //     );
  //     return userCredentials.user;
  //   } catch (err) {
  //     print('login error: $err');
  //     throw Exception(err);
  //   }
  // }

  // @override
  // Future<void> sendLoginEmailLink({
  //   required String email,
  // }) async {
  //   try {
  //     await _firebaseAuth.sendSignInLinkToEmail(
  //       email: email,
  //       actionCodeSettings: auth.ActionCodeSettings(
  //         url: '', // TODO: add for web
  //         handleCodeInApp: true,
  //         iOSBundleId: 'com.dtfun.appsAgainstFellowship',
  //         androidInstallApp: true,
  //         androidMinimumVersion: '21',
  //         androidPackageName: 'com.dtfun.apps_against_fellowship',
  //       ),
  //     );
  //   } catch (err) {
  //     print('login error: $err');
  //   }
  // }

  /// Log out
  Future<void> signOut() async {
    if (_googleSignIn.currentUser != null) {
      print('have google user');
      try {
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect();
      } catch (err) {
        print('google error signing out: $err');
      }
    }
    if (_firebaseAuth.currentUser != null) {
      print('have firebase user');
      try {
        await _firebaseAuth.signOut();
      } catch (err) {
        print('firebase error signing out: $err');
      }
    }
  }
}
