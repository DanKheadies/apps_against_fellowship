import 'package:equatable/equatable.dart';

import 'package:apps_against_fellowship/models/models.dart';

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
    Map<String, List<ResponseCard>> responsesMap = {}; // TODO (?)
    if (json['responses'] != null) {
      print('not null');
      responsesMap = (json['responses'] as Map<String, List<ResponseCard>>).map(
        (k, v) => MapEntry(
          k,
          v.map((dynamic card) => ResponseCard.fromJson(card)).toList(),
        ),
      );
    }

    return Turn(
      judgeId: json['judgeId'] ?? '',
      promptCard: PromptCard.fromJson(json['promptCard']),
      responses: responsesMap,
      winner: TurnWinner.fromJson(json['winner']),
    );
  }

  Map<String, dynamic> toJson() {
    // TODO: the right route for a map like responses

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
