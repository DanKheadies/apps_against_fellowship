part of 'authentication_cubit.dart';

enum AuthenticationStatus {
  initial,
  submitting,
  success,
  error,
}

class AuthenticationState extends Equatable {
  final String email;
  final String password;
  final AuthenticationStatus status;
  final String? errorMessage;

  const AuthenticationState({
    required this.email,
    required this.password,
    required this.status,
    this.errorMessage,
  });

  bool get isFormValid => email.isNotEmpty && password.isNotEmpty;

  factory AuthenticationState.initial() {
    return const AuthenticationState(
      email: '',
      password: '',
      status: AuthenticationStatus.initial,
      errorMessage: '',
    );
  }

  AuthenticationState copyWith({
    String? email,
    String? password,
    AuthenticationStatus? status,
    String? errorMessage,
  }) {
    return AuthenticationState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        status,
        errorMessage,
      ];
}
