import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';

class UserGame extends Equatable {
  final DateTime? joinedAt;
  final GameState gameState;
  final String gid;
  final String id;

  const UserGame({
    required this.gameState,
    required this.gid,
    required this.id,
    this.joinedAt,
  });

  @override
  List<Object?> get props => [
        gameState,
        gid,
        id,
        joinedAt,
      ];

  UserGame copyWith({
    DateTime? joinedAt,
    GameState? gameState,
    String? gid,
    String? id,
  }) {
    return UserGame(
      gameState: gameState ?? this.gameState,
      gid: gid ?? this.gid,
      id: id ?? this.id,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  factory UserGame.fromSnapshot(DocumentSnapshot snap) {
    dynamic data = snap.data();
    DateTime joined = data['joinedAt'] != null
        ? (data['joinedAt'] as Timestamp).toDate()
        : DateTime.now();

    return UserGame(
      gameState: data['gameState'] ?? GameState.emptyGame,
      gid: data['gid'] ?? '',
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
      gid: json['gid'] ?? '',
      id: json['id'] ?? '',
      joinedAt: joined,
    );
  }

  Map<String, dynamic> toSnap() {
    return {
      'gameState': gameState.toJson(),
      'gid': gid,
      'id': id,
      'joinedAt': joinedAt?.toUtc(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'gameState': gameState.toJson(),
      'gid': gid,
      'id': id,
      'joinedAt': joinedAt.toString(),
    };
  }

  static const emptyUserGame = UserGame(
    gameState: GameState.emptyGame,
    gid: '',
    id: '',
    // joinedAt: DateTime.now(),
  );
}
