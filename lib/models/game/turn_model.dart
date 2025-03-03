import 'package:apps_against_fellowship/models/models.dart';
import 'package:equatable/equatable.dart';

class Turn extends Equatable {
  final Map<String, List<ResponseCard>> responses;
  final PromptCard promptCard;
  final String judgeId;
  final TurnWinner? winner;

  const Turn({
    required this.judgeId,
    required this.promptCard,
    required this.responses,
    this.winner,
  });

  @override
  List<Object?> get props => [
        judgeId,
        promptCard,
        responses,
        winner,
      ];

  Turn copyWith({
    Map<String, List<ResponseCard>>? responses,
    PromptCard? promptCard,
    String? judgeId,
    TurnWinner? winner,
  }) {
    return Turn(
      judgeId: judgeId ?? this.judgeId,
      promptCard: promptCard ?? this.promptCard,
      responses: responses ?? this.responses,
      winner: winner ?? this.winner,
    );
  }

  factory Turn.fromJson(Map<String, dynamic> json) {
    Map<String, List<ResponseCard>> responsesMap = {};
    PromptCard prompt = PromptCard.emptyPromptCard;
    TurnWinner turnWin = TurnWinner.emptyTurnWinner;

    if (json['promptCard'] != null) {
      prompt = PromptCard.fromJson(json['promptCard']);
    }

    if (json['responses'] != {}) {
      responsesMap = (json['responses'] as Map).map(
        (k, v) => MapEntry(
          k,
          (v as List)
              .map((dynamic card) => ResponseCard.fromJson(card))
              .toList(),
        ),
      );
    }

    if (json['winner'] != null) {
      turnWin = TurnWinner.fromJson(json['winner']);
    }

    return Turn(
      judgeId: json['judgeId'] ?? '',
      promptCard: prompt,
      responses: responsesMap,
      winner: turnWin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judgeId': judgeId,
      'promptCard': promptCard.toJson(),
      'responses': responses,
      'winner': winner?.toJson(),
    };
  }

  static const emptyTurn = Turn(
    judgeId: '',
    promptCard: PromptCard.emptyPromptCard,
    responses: {},
  );
}
