part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

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

// class AuthGoogleUserChanged extends AuthEvent {
//   final GoogleSignInAccount authGoogleUser;

//   const AuthGoogleUserChanged({
//     required this.authGoogleUser,
//   });

//   @override
//   List<Object?> get props => [
//         authGoogleUser,
//       ];
// }

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
  const LoginWithGoogle();

  @override
  List<Object?> get props => [];
}

class LoginWithGoogleSilently extends AuthEvent {
  const LoginWithGoogleSilently();

  @override
  List<Object?> get props => [];
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
