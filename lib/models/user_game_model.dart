import 'package:apps_against_fellowship/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserGame extends Equatable {
  final DateTime? joinedAt;
  final GameStatus gameStatus;
  final String gameId;
  final String id;

  const UserGame({
    required this.gameStatus,
    required this.gameId,
    required this.id,
    this.joinedAt,
  });

  @override
  List<Object?> get props => [
        gameStatus,
        gameId,
        id,
        joinedAt,
      ];

  UserGame copyWith({
    DateTime? joinedAt,
    GameStatus? gameStatus,
    String? gameId,
    String? id,
  }) {
    return UserGame(
      gameStatus: gameStatus ?? this.gameStatus,
      gameId: gameId ?? this.gameId,
      id: id ?? this.id,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  factory UserGame.fromSnapshot(DocumentSnapshot snap) {
    dynamic data = snap.data();

    DateTime? joined =
        data['joinedAt'] != null ? DateTime.parse(data['joinedAt']) : null;
    GameStatus status = GameStatus.values.firstWhere(
      (stat) => stat.name.toString() == data['gameStatus'],
    );

    return UserGame(
      gameStatus: status,
      gameId: data['gameId'] ?? '',
      id: snap.id,
      joinedAt: joined,
    );
  }

  factory UserGame.fromJson(Map<String, dynamic> json) {
    DateTime? joined = json['joinedAt'] != null
        ? (json['joinedAt'] as Timestamp).toDate()
        : null;
    GameStatus status = GameStatus.values.firstWhere(
      (stat) => stat.name.toString() == json['gameStatus'],
    );

    return UserGame(
      gameStatus: status,
      gameId: json['gameId'] ?? '',
      id: json['id'] ?? '',
      joinedAt: joined,
    );
  }

  Map<String, dynamic> toSnap() {
    return {
      'gameState': gameStatus.name,
      'gameId': gameId,
      'id': id,
      'joinedAt': joinedAt?.toUtc(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'gameState': gameStatus.name,
      'gameId': gameId,
      'id': id,
      'joinedAt': joinedAt.toString(),
    };
  }

  static const emptyUserGame = UserGame(
    gameStatus: GameStatus.waitingRoom,
    gameId: '',
    id: '',
  );
}
