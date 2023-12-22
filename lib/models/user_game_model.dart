import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserGame extends Equatable {
  final DateTime joinedAt;
  // final GameState gameState;
  final String gid;
  final String id;

  const UserGame({
    // required this.gameState,
    required this.gid,
    required this.id,
    required this.joinedAt,
  });

  @override
  List<Object> get props => [
        // gameState,
        gid,
        id,
        joinedAt,
      ];

  UserGame copyWith({
    DateTime? joinedAt,
    // GameState? gameState,
    String? gid,
    String? id,
  }) {
    return UserGame(
      // gameState: gameState ?? this.gameState,
      gid: gid ?? this.gid,
      id: id ?? this.id,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  factory UserGame.fromSnapshot(DocumentSnapshot snap) {
    dynamic data = snap.data();

    return UserGame(
      // gameState: data['gameState'] ?? GameState.emptyGame,
      gid: data['gid'] ?? '',
      id: snap.id,
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }

  factory UserGame.fromJson(Map<String, dynamic> json) {
    return UserGame(
      // gameState: json['gameState'] ?? GameState.emptyGame,
      gid: json['gid'] ?? '',
      id: json['id'] ?? '',
      joinedAt: (json['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'gameState': gameState,
      'gid': gid,
      'id': id,
      'joinedAt': joinedAt.toString(),
    };
  }

  static final emptyUserGame = UserGame(
    // gameState: GameState.emptyGame,
    gid: '',
    id: '',
    joinedAt: DateTime.now(),
  );
}
