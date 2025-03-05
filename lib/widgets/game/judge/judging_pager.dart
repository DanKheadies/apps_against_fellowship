import 'dart:math';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';

class JudgingPager extends StatelessWidget {
  final GameState state;
  final JudgementController controller;

  const JudgingPager({
    super.key,
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    var responses = state.game.turn?.responses ?? {};
    // print('responses: $responses');
    var playerResponses = responses.entries
        .map(
          (e) => PlayerResponse(
            playerId: e.key,
            responses: e.value.toList(),
          ),
        )
        .toList();
    playerResponses.shuffle(Random(state.game.round));
    controller.setCurrentResponse(
      playerResponses[0],
      0,
      playerResponses.length,
    );
    // print('derp');
    // print(playerResponses[0].responses);

    return PageView.builder(
      controller: controller.pageController,
      itemCount: playerResponses.length,
      itemBuilder: (context, index) {
        var response = playerResponses[index];
        // print(response.responses);
        // Note: when retrieved, they appear to be reversed or don't maintain
        // their order, i.e. Pick 2 - 2nd card is 1st, 1st card is next, and
        // Pick 3 - 2nd card is 1st, 1st card is 2nd, and 3rd card is 3rd.
        // Update: I think that's coincidental. I think it's organizing the
        // responses by ID in Firebase fashion number > uppercase > lowercase.
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: buildResponseCardStack(
            // response.responses.reversed.toList(),
            response.responses,
            lastChild: const SizedBox(),
          ),
        );
      },
      onPageChanged: (index) {
        // Analytics().logSelectContent(
        //     contentType: 'judge', itemId: 'response_change_$index');
        var playerResponse = playerResponses[index];
        controller.setCurrentResponse(
          playerResponse,
          index,
          playerResponses.length,
        );
      },
    );
  }
}
