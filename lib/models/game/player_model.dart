import 'package:apps_against_fellowship/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Player extends Equatable {
  static const defaultName = '"A player needs a name"';

  final bool isInactive;
  final bool isRandoCardrissian;
  final List<PromptCard>? prizes;
  final List<ResponseCard>? hand;
  final String id;
  final String name;
  final String? avatarUrl;

  const Player({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.hand = const [],
    this.isInactive = false,
    this.isRandoCardrissian = false,
    this.prizes = const [],
  });

  @override
  List<Object?> get props => [
        avatarUrl,
        hand,
        id,
        isInactive,
        isRandoCardrissian,
        name,
        prizes,
      ];

  Player copyWith({
    bool? isInactive,
    bool? isRandoCardrissian,
    List<PromptCard>? prizes,
    List<ResponseCard>? hand,
    String? avatarUrl,
    String? id,
    String? name,
  }) {
    return Player(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hand: hand ?? this.hand,
      id: id ?? this.id,
      isInactive: isInactive ?? this.isInactive,
      isRandoCardrissian: isRandoCardrissian ?? this.isRandoCardrissian,
      name: name ?? this.name,
      prizes: prizes ?? this.prizes,
    );
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    List<PromptCard> prizesList = (json['prizes'] as List)
        .map((prize) => PromptCard.fromJson(prize))
        .toList();
    List<ResponseCard> handList = (json['hand'] as List)
        .map((card) => ResponseCard.fromJson(card))
        .toList();

    return Player(
      avatarUrl: json['avatarUrl'] ?? '',
      hand: handList,
      id: json['id'] ?? '',
      isInactive: json['isInactive'] ?? false,
      isRandoCardrissian: json['isRandoCardrissian'] ?? false,
      name: json['name'] ?? '',
      prizes: prizesList,
    );
  }

  factory Player.fromSnapshot(DocumentSnapshot snap) {
    dynamic data = snap.data();

    List<PromptCard> prizesList = [];
    List<ResponseCard> handList = [];

    if (data['prizes'] != null) {
      (data['prizes'] as List)
          .map((prize) => PromptCard.fromJson(prize))
          .toList();
    }
    if (data['hand'] != null) {
      (data['hand'] as List)
          .map((card) => ResponseCard.fromJson(card))
          .toList();
    }

    return Player(
      avatarUrl: data['avatarUrl'] ?? '',
      hand: handList,
      id: snap.id,
      isInactive: data['isInactive'] ?? false,
      isRandoCardrissian: data['isRandoCardrissian'] ?? false,
      name: data['name'] ?? '',
      prizes: prizesList,
    );
  }

  Map<String, dynamic> toJson() {
    // TODO: is this the right route for a complex list (?); List<CustomModel>
    var handList = [];
    var prizesList = [];

    if (hand != null) {
      for (var card in hand!) {
        handList.add(card.toJson());
      }
    }
    if (prizes != null) {
      for (var card in prizes!) {
        prizesList.add(card.toJson());
      }
    }

    return {
      'avatarUrl': avatarUrl,
      'hand': handList,
      'id': id,
      'isInactive': isInactive,
      'isRandoCardrissian': isRandoCardrissian,
      'name': name,
      'prizes': prizesList,
    };
  }

  static const emptyPlayer = Player(
    avatarUrl: '',
    hand: [],
    id: '',
    isInactive: false,
    isRandoCardrissian: false,
    name: '',
    prizes: [],
  );
}
