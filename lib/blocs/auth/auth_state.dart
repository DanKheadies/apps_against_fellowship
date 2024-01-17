part of 'auth_bloc.dart';

enum AuthStatus {
  authenticated,
  submitting,
  unauthenticated,
  unknown,
}

class AuthState extends Equatable {
  final auth.User? authUser;
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.authUser,
    this.errorMessage,
    this.status = AuthStatus.unknown,
  });

  @override
  List<Object?> get props => [
        authUser,
        errorMessage,
        status,
      ];

  AuthState copyWith({
    auth.User? authUser,
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      authUser: authUser ?? this.authUser,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      errorMessage: json['errorMessage'],
      status: AuthStatus.values.firstWhere(
        (status) => status.name.toString() == json['status'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorMessage': errorMessage,
      'status': status.name,
    };
  }
}
