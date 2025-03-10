part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// class Derp extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final auth.User? authUser;

  const AuthUserChanged({
    this.authUser,
  });

  @override
  List<Object?> get props => [
        authUser,
      ];
}

class AuthGoogleUserChanged extends AuthEvent {
  final GoogleSignInAccount? account;

  const AuthGoogleUserChanged({
    this.account,
  });

  @override
  List<Object?> get props => [
        account,
      ];
}

class LoginWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailAndPassword({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [
        email,
        password,
      ];
}

class LoginWithGoogle extends AuthEvent {
  final bool isSilent;

  const LoginWithGoogle({
    this.isSilent = false,
  });

  @override
  List<Object?> get props => [
        isSilent,
      ];
}

class LoginWithLink extends AuthEvent {
  final String email;
  final String emailLink;

  const LoginWithLink({
    required this.email,
    required this.emailLink,
  });

  @override
  List<Object?> get props => [
        email,
        emailLink,
      ];
}

class RegisterAnonymously extends AuthEvent {}

class RegisterWithEmailAndPassword extends AuthEvent {
  final String email;
  final String name;
  final String password;

  const RegisterWithEmailAndPassword({
    required this.email,
    required this.name,
    required this.password,
  });

  @override
  List<Object?> get props => [
        email,
        name,
        password,
      ];
}

class ResetError extends AuthEvent {}

class ResetPassword extends AuthEvent {
  final String email;

  const ResetPassword({
    required this.email,
  });

  @override
  List<Object?> get props => [
        email,
      ];
}

class SignOut extends AuthEvent {}
