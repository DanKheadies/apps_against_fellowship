part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final auth.User? authUser;

  const AuthUserChanged({
    required this.authUser,
  });

  @override
  List<Object?> get props => [
        authUser,
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

class LoginWithGoogle extends AuthEvent {
  final String email;
  final String password;

  const LoginWithGoogle({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [
        email,
        password,
      ];
}

class RegisterAnonymously extends AuthEvent {}

class RegisterWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;

  const RegisterWithEmailAndPassword({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [
        email,
        password,
      ];
}

class ResetError extends AuthEvent {}

class SignOut extends AuthEvent {}
