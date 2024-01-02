import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';

class AuthRepository extends BaseAuthRepository {
  final auth.FirebaseAuth _firebaseAuth;
  final DatabaseRepository _databaseRepository;

  AuthRepository({
    auth.FirebaseAuth? firebaseAuth,
    required DatabaseRepository databaseRepository,
  })  : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
        _databaseRepository = databaseRepository;

  @override
  auth.User? getUser() {
    try {
      final currentUser = _firebaseAuth.currentUser;
      // print('current user: $currentUser');
      return currentUser;
    } catch (err) {
      print('get user err: $err');
      throw Exception(err);
    }
  }

  @override
  Stream<auth.User?> get user => _firebaseAuth.userChanges();

  @override
  Future<auth.User?> loginWithEmail({
    required String email,
    required String emailLink,
  }) async {
    try {
      final userCredentials = await _firebaseAuth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );
      return userCredentials.user;
    } catch (err) {
      print('login error: $err');
      throw Exception(err);
    }
  }

  @override
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

  @override
  Future<auth.User?> registerUser({
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

      await _databaseRepository.createUser(
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

  @override
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

  @override
  Future<void> sendLoginEmailLink({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: auth.ActionCodeSettings(
          url: '', // TODO: add for web
          handleCodeInApp: true,
          iOSBundleId: 'com.dtfun.appsAgainstFellowship',
          androidInstallApp: true,
          androidMinimumVersion: '21',
          androidPackageName: 'com.dtfun.apps_against_fellowship',
        ),
      );
    } catch (err) {
      print('login error: $err');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
