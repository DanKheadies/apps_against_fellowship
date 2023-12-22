import 'package:firebase_auth/firebase_auth.dart' as auth;

// import 'package:apps_against_fellowship/models/models.dart';

abstract class BaseAuthRepository {
  Stream<auth.User?> get user;
  Future<auth.User?> loginWithEmail({
    required String email,
    required String emailLink,
  });
  Future<auth.User?> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<auth.User?> registerUser({
    required String email,
    required String password,
    String? name,
  });
  Future<void> resetPassword({
    required String email,
  });
  Future<void> sendLoginEmailLink({
    required String email,
  });
  Future<void> signOut();
}
