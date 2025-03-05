import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';

class WaitingPlayerResponses extends StatelessWidget {
  final GameState state;

  const WaitingPlayerResponses({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    var players = state.players.where((element) {
      return element.id != state.game.turn?.judgeId &&
          element.isInactive != true;
    }).toList();

    var columnCount = 3;
    if (MediaQuery.of(context).size.width >= 600) {
      columnCount = 9;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.surfaceDim,
          ),
          Expanded(
            child: GridView.builder(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 8,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnCount,
                  childAspectRatio: 88 / 130,
                ),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  var player = players[index];
                  var hasSubmittedResponse =
                      state.game.turn?.responses.containsKey(player.id) ??
                          false;
                  return PlayerResponseCard(
                    player: player,
                    hasSubmittedResponse: hasSubmittedResponse,
                  );
                }),
          ),
        ],
      ),
    );
  }
}
