import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:apps_against_fellowship/models/models.dart';

enum GameStatus {
  completed,
  inProgress,
  starting,
  waitingRoom,
}

extension GameStatusExt on GameStatus {
  String get label {
    switch (this) {
      case GameStatus.waitingRoom:
        return 'Waiting Room';
      case GameStatus.starting:
        return 'Game Starting';
      case GameStatus.inProgress:
        return 'In Progress';
      default:
        return 'Completed';
    }
  }
}

class Game extends Equatable {
  static const initPrizesToWin = 7;
  static const initPlayerLimit = 30;

  final bool draw2Pick3Enabled;
  final bool pick2Enabled;
  final GameStatus gameStatus;
  final int playerLimit;
  final int prizesToWin;
  final int round;
  final List<String>? judgeRotation;
  final Set<String> cardSets;
  final String gameId;
  final String id;
  final String ownerId;
  final String? winner;
  final Turn? turn;

  const Game({
    required this.cardSets,
    required this.gameId,
    required this.gameStatus,
    required this.id, // TODO: required (?)
    required this.ownerId,
    this.draw2Pick3Enabled = true,
    this.judgeRotation,
    this.pick2Enabled = true,
    this.playerLimit = initPlayerLimit,
    this.prizesToWin = initPrizesToWin,
    this.round = 1,
    this.turn,
    this.winner,
  });

  @override
  List<Object?> get props => [
        cardSets,
        draw2Pick3Enabled,
        gameId,
        gameStatus,
        id,
        judgeRotation,
        ownerId,
        pick2Enabled,
        playerLimit,
        prizesToWin,
        round,
        turn,
        winner,
      ];

  Game copyWith({
    bool? draw2Pick3Enabled,
    bool? pick2Enabled,
    GameStatus? gameStatus,
    int? playerLimit,
    int? prizesToWin,
    int? round,
    List<String>? judgeRotation,
    Set<String>? cardSets,
    String? gameId,
    String? id,
    String? ownerId,
    String? winner,
    Turn? turn,
  }) {
    return Game(
      cardSets: cardSets ?? this.cardSets,
      draw2Pick3Enabled: draw2Pick3Enabled ?? this.draw2Pick3Enabled,
      gameId: gameId ?? this.gameId,
      gameStatus: gameStatus ?? this.gameStatus,
      id: id ?? this.id,
      judgeRotation: judgeRotation ?? this.judgeRotation,
      ownerId: ownerId ?? this.ownerId,
      pick2Enabled: pick2Enabled ?? this.pick2Enabled,
      playerLimit: playerLimit ?? this.playerLimit,
      prizesToWin: prizesToWin ?? this.prizesToWin,
      round: round ?? this.round,
      turn: turn ?? this.turn,
      winner: winner ?? this.winner,
    );
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    List<String> judgeRotationList = [];
    if (json['judgeRotation'] != null) {
      judgeRotationList = (json['judgeRotation'] as List)
          .map((judge) => judge as String)
          .toList();
    }

    // TODO
    Set<String> cardSetsSet = {};

    return Game(
      cardSets: cardSetsSet,
      draw2Pick3Enabled: json['draw2Pick3Enabled'] ?? true,
      gameId: json['gameId'] ?? '',
      gameStatus: GameStatus.values.firstWhere(
        (status) => status.name.toString() == json['gameStatus'],
      ),
      id: json['id'] ?? '',
      judgeRotation: judgeRotationList,
      ownerId: json['ownerId'] ?? '',
      pick2Enabled: json['pick2Enabled'] ?? true,
      playerLimit: json['playerLimit'] ?? initPlayerLimit,
      prizesToWin: json['prizesToWin'] ?? initPrizesToWin,
      round: json['round'] ?? 1,
      turn: json['turn'] ?? Turn.emptyTurn,
      winner: json['winner'] ?? '',
    );
  }

  factory Game.fromSnapshot(DocumentSnapshot snap) {
    dynamic data = snap.data();
    return Game.fromJson(data).copyWith(
      id: snap.id,
    );
  }

  Map<String, dynamic> toJson() {
    // TODO: is this the right route for a complex list (?); List<CustomModel>
    // var judgeRotationList = [];
    // for (var judgePos in judgeRotation!) {
    //   judgeRotationList.add(judgePos.toJson());
    // }

    return {
      'cardSets': cardSets,
      'draw2Pick3Enabled': draw2Pick3Enabled,
      'gameId': gameId,
      'gameStatus': gameStatus.name,
      'id': id,
      'judgeRotation': judgeRotation,
      'ownerId': ownerId,
      'pick2Enabled': pick2Enabled,
      'playerLimit': playerLimit,
      'prizesToWin': prizesToWin,
      'round': round,
      'turn': turn,
      'winner': winner,
    };
  }

  static const emptyGame = Game(
    cardSets: {},
    draw2Pick3Enabled: true,
    gameId: '',
    gameStatus: GameStatus.waitingRoom,
    id: '',
    ownerId: '',
    pick2Enabled: true,
    playerLimit: initPlayerLimit,
    prizesToWin: initPrizesToWin,
    round: 1,
  );
}
