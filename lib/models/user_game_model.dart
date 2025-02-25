import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserGame extends Equatable {
  final DateTime? joinedAt;
  final GameState gameState;
  final String gameId;
  final String id;

  const UserGame({
    required this.gameState,
    required this.gameId,
    required this.id,
    this.joinedAt,
  });

  @override
  List<Object?> get props => [
        gameState,
        gameId,
        id,
        joinedAt,
      ];

  UserGame copyWith({
    DateTime? joinedAt,
    GameState? gameState,
    String? gameId,
    String? id,
  }) {
    return UserGame(
      gameState: gameState ?? this.gameState,
      gameId: gameId ?? this.gameId,
      id: id ?? this.id,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  factory UserGame.fromSnapshot(DocumentSnapshot snap) {
    print('from SNAP');
    dynamic data = snap.data();
    print(data);

    DateTime joined = data['joinedAt'] != null
        ? DateTime.parse(data['joinedAt'])
        : DateTime.now();

    return UserGame(
      gameState: data['gameState'] ?? GameState.emptyGame,
      gameId: data['gameId'] ?? '',
      id: snap.id,
      joinedAt: joined,
    );
  }

  factory UserGame.fromJson(Map<String, dynamic> json) {
    DateTime joined = json['joinedAt'] != null
        ? (json['joinedAt'] as Timestamp).toDate()
        : DateTime.now();

    return UserGame(
      gameState: json['gameState'] ?? GameState.emptyGame,
      gameId: json['gameId'] ?? '',
      id: json['id'] ?? '',
      joinedAt: joined,
    );
  }

  Map<String, dynamic> toSnap() {
    return {
      'gameState': gameState.toJson(),
      'gameId': gameId,
      'id': id,
      'joinedAt': joinedAt?.toUtc(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'gameState': gameState.toJson(),
      'gameId': gameId,
      'id': id,
      'joinedAt': joinedAt.toString(),
    };
  }

  static const emptyUserGame = UserGame(
    gameState: GameState.emptyGame,
    gameId: '',
    id: '',
    // joinedAt: DateTime.now(),
  );
}
