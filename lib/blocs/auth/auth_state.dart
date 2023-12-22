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
  final User? user;

  const AuthState({
    this.authUser,
    this.errorMessage,
    this.status = AuthStatus.unknown,
    this.user,
  });

  @override
  List<Object?> get props => [
        authUser,
        errorMessage,
        status,
        user,
      ];

  AuthState copyWith({
    auth.User? authUser,
    AuthStatus? status,
    String? errorMessage,
    User? user,
  }) {
    return AuthState(
      authUser: authUser ?? this.authUser,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }

  factory AuthState.fromJson(Map<String, dynamic> json) {
    print('auth state fromJson');
    return AuthState(
      // Note: would need a custom AuthUser model to handle authUser
      // authUser: null,
      errorMessage: json['errorMessage'],
      status: AuthStatus.values.firstWhere(
        (status) => status.name.toString() == json['status'],
      ),
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    print('auth state toJson');
    var jsonUser = user != null ? user!.toJson() : null;
    return {
      // Note: would need a custom AuthUser model to handle authUser
      // 'authUser': authUser.toString(),
      'errorMessage': errorMessage,
      'status': status.name,
      'user': jsonUser,
    };
  }
}
