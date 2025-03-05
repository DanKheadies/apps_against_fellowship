import 'dart:math';

import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';

class OtherResponsesPager extends StatefulWidget {
  final int gameRound;
  final Map<String, List<ResponseCard>> responses;
  final String winningPlayerId;

  const OtherResponsesPager({
    super.key,
    required this.winningPlayerId,
    required this.gameRound,
    required this.responses,
  });

  @override
  OtherResponsesPagerState createState() => OtherResponsesPagerState();
}

class OtherResponsesPagerState extends State<OtherResponsesPager> {
  static const double viewportFraction = 0.93;

  final PageController pageController =
      PageController(viewportFraction: viewportFraction);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var responses = widget.responses;
    var playerResponses = responses.entries
        .map(
          (e) => PlayerResponse(
            playerId: e.key,
            responses: e.value.toList(),
          ),
        )
        .where(
          (element) => element.playerId != widget.winningPlayerId,
        )
        .toList();
    playerResponses.shuffle(Random(widget.gameRound));

    return PageView.builder(
      controller: pageController,
      itemCount: playerResponses.length,
      itemBuilder: (context, index) {
        var response = playerResponses[index];
        // print(response.responses);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: buildResponseCardStack(
            response.responses,
            lastChild: const SizedBox(),
          ),
        );
      },
    );
  }
}
