import 'package:apps_against_fellowship/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TurnWinner extends Equatable {
  final bool isRandoCardrissian;
  final List<ResponseCard> response;
  final Map<String, List<ResponseCard>>? responses;
  final PromptCard promptCard;
  final String playerAvatarUrl;
  final String playerId;
  final String playerName;

  const TurnWinner({
    required this.isRandoCardrissian,
    required this.playerAvatarUrl,
    required this.playerId,
    required this.playerName,
    required this.promptCard,
    required this.response,
    this.responses = const {},
  });

  @override
  List<Object?> get props => [
        isRandoCardrissian,
        playerAvatarUrl,
        playerId,
        playerName,
        promptCard,
        response,
        responses,
      ];

  TurnWinner copyWith({
    bool? isRandoCardrissian,
    List<ResponseCard>? response,
    Map<String, List<ResponseCard>>? responses,
    PromptCard? promptCard,
    String? playerAvatarUrl,
    String? playerId,
    String? playerName,
  }) {
    return TurnWinner(
      isRandoCardrissian: isRandoCardrissian ?? this.isRandoCardrissian,
      playerAvatarUrl: playerAvatarUrl ?? this.playerAvatarUrl,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      promptCard: promptCard ?? this.promptCard,
      response: response ?? this.response,
      responses: responses ?? this.responses,
    );
  }

  factory TurnWinner.fromJson(Map<String, dynamic> json) {
    List<ResponseCard> responseList = (json['response'] as List)
        .map((card) => ResponseCard.fromJson(card))
        .toList();

    Map<String, List<ResponseCard>> responsesMap = {};
    if (json['responses'] != null || json['responses'] != {}) {
      responsesMap = (json['responses'] as Map).map(
        (k, v) => MapEntry(
          k,
          (v as List)
              .map((dynamic card) => ResponseCard.fromJson(card))
              .toList(),
        ),
      );
    }

    return TurnWinner(
      isRandoCardrissian: json['isRandoCardrissian'] ?? false,
      playerAvatarUrl: json['playerAvatarUrl'] ?? '',
      playerId: json['playerId'] ?? '',
      playerName: json['playerName'] ?? '',
      promptCard: PromptCard.fromJson(json['promptCard']),
      response: responseList,
      responses: responsesMap,
    );
  }

  factory TurnWinner.fromSnapshot(DocumentSnapshot snap) {
    dynamic data = snap.data();

    List<ResponseCard> responseList = (data['response'] as List)
        .map((card) => ResponseCard.fromJson(card))
        .toList();
    Map<String, List<ResponseCard>> responsesMap = {};
    if (data['responses'] != null || data['responses'] != {}) {
      // TODO - Added != {}; see if that messes anything up
      responsesMap = (data['responses'] as Map).map(
        (k, v) => MapEntry(
          k,
          (v as List)
              .map((dynamic card) => ResponseCard.fromJson(card))
              .toList(),
        ),
      );
    }

    return TurnWinner(
      isRandoCardrissian: data['isRandoCardrissian'] ?? false,
      playerAvatarUrl: data['playerAvatarUrl'] ?? '',
      playerId: data['playerId'] ?? '',
      playerName: data['playerName'] ?? '',
      promptCard: PromptCard.fromJson(data['promptCard']),
      response: responseList,
      responses: responsesMap,
    );
  }

  Map<String, dynamic> toJson() {
    var responseList = [];

    for (var card in response) {
      responseList.add(card.toJson());
    }

    return {
      'isRandoCardrissian': isRandoCardrissian,
      'playerAvatarUrl': playerAvatarUrl,
      'playerId': playerId,
      'playerName': playerName,
      'promptCard': promptCard.toJson(),
      'response': responseList,
      'responses': responses,
    };
  }

  static const emptyTurnWinner = TurnWinner(
    isRandoCardrissian: false,
    playerAvatarUrl: '',
    playerId: '',
    playerName: '',
    promptCard: PromptCard.emptyPromptCard,
    response: [],
    responses: {},
  );
}
