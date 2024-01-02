part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final auth.User? authUser;
  // final User? user;

  const AuthUserChanged({
    required this.authUser,
    // this.user,
  });

  @override
  List<Object?> get props => [
        authUser,
        // user,
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

// class UpdateAuthsUser extends AuthEvent {
//   final User user;

//   const UpdateAuthsUser({
//     required this.user,
//   });

//   @override
//   List<Object?> get props => [
//         user,
//       ];
// }

class SignOut extends AuthEvent {}
