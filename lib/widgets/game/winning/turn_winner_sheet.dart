import 'package:flutter/material.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class TurnWinnerSheet extends StatelessWidget {
  final GameState state;
  final TurnWinner? turnWinner;
  final ScrollController scrollController;

  const TurnWinnerSheet({
    super.key,
    required this.scrollController,
    required this.state,
    this.turnWinner,
  });
  // : turnWinner = state.game.turn.winner;

  @override
  Widget build(BuildContext context) {
    var playerName = turnWinner!.playerName;
    if (playerName.trim().isEmpty) {
      playerName = Player.defaultName;
    }
    return SizedBox.expand(
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Winner!',
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
            Container(
              child: _buildAvatar(context),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Text(
                playerName,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
            Container(
              height: 850,
              margin: const EdgeInsets.only(top: 24),
              child: PromptCardView(
                state: state,
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: buildResponseCardStack(
                    turnWinner!.response,
                    lastChild: Column(
                      children: [
                        const Divider(),
                        Container(
                          margin: const EdgeInsets.only(top: 8, left: 20),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Player Responses'.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  // color: AppColors.primaryVariant,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 16),
                            child: OtherResponsesPager(
                              winningPlayerId: turnWinner!.playerId,
                              gameRound: state.game.round - 1,
                              responses: turnWinner!.responses!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return PlayerCircleAvatar(
      radius: 40,
      player: Player(
        id: turnWinner!.playerId,
        name: turnWinner!.playerName,
        avatarUrl: turnWinner!.playerAvatarUrl,
        isRandoCardrissian: turnWinner!.isRandoCardrissian,
      ),
    );
  }
}
