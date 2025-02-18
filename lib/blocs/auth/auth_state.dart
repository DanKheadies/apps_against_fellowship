part of 'auth_bloc.dart';

enum AuthStatus {
  authenticated,
  submitting,
  unauthenticated,
  unknown,
}

class AuthState extends Equatable {
  final auth.User? authUser;
  final auth.UserCredential? authGoogleUser;
  final AuthStatus status;
  final DateTime? lastUpdate;
  final String? errorMessage;

  const AuthState({
    this.authUser,
    this.authGoogleUser,
    this.errorMessage,
    this.lastUpdate,
    this.status = AuthStatus.unknown,
  });

  @override
  List<Object?> get props => [
        authUser,
        authGoogleUser,
        errorMessage,
        lastUpdate,
        status,
      ];

  AuthState copyWith({
    auth.User? authUser,
    auth.UserCredential? authGoogleUser,
    AuthStatus? status,
    DateTime? lastUpdate,
    String? errorMessage,
  }) {
    return AuthState(
      authUser: authUser ?? this.authUser,
      authGoogleUser: authGoogleUser ?? this.authGoogleUser,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      status: status ?? this.status,
    );
  }

  factory AuthState.fromJson(Map<String, dynamic> json) {
    DateTime updatedTime = json['lastUpdate'] != null
        ? DateTime.parse(json['lastUpdate'])
        : DateTime.now();

    return AuthState(
      errorMessage: json['errorMessage'],
      lastUpdate: updatedTime,
      status: AuthStatus.values.firstWhere(
        (status) => status.name.toString() == json['status'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    DateTime lastDT = lastUpdate ?? DateTime.now();

    return {
      'errorMessage': errorMessage,
      'lastUpdate': lastDT.toString(),
      'status': status.name,
    };
  }
}
