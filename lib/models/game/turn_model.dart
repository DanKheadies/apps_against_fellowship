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
    // print('turn fromJson');
    // print(json);

    Map<String, List<ResponseCard>> responsesMap = {};
    PromptCard prompt = PromptCard.emptyPromptCard;
    TurnWinner turnWin = TurnWinner.emptyTurnWinner;

    // if (json['responses'] != null && json['responses'] != {}) {
    // print('not null');
    // print(json['responses']);
    // print((json['responses'] as Map));
    // print('do it..');
    // Note: somehow this works.. clean up
    // responsesMap = (json['responses'] as Map).map(
    //   (k, v) {
    //     print('derp');
    //     print('key: $k');
    //     print('value1: $v');
    //     var value = (v as List);
    //     print('value2: $value');
    //     return MapEntry(
    //       k,
    //       value.map((dynamic card) {
    //         print('test');
    //         print(card);
    //         return ResponseCard.fromJson(card);
    //       }).toList(),
    //     );
    //   },
    // );
    if (json['responses'] != {}
        // && json['responses'] != null
        ) {
      responsesMap = (json['responses'] as Map).map(
        (k, v) => MapEntry(
          k,
          (v as List)
              .map((dynamic card) => ResponseCard.fromJson(card))
              .toList(),
        ),
      );
    }
    // print('alpha');
    // print(responsesMap);

    if (json['promptCard'] != null) {
      prompt = PromptCard.fromJson(json['promptCard']);
    }

    if (json['winner'] != null) {
      // print('beta');
      turnWin = TurnWinner.fromJson(json['winner']);
    }
    // print('sending turn info');

    Turn derp = Turn(
      judgeId: json['judgeId'],
      promptCard: prompt,
      responses: responsesMap,
      winner: turnWin,
    );
    // print('derp');
    // print(derp);
    return derp;
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
