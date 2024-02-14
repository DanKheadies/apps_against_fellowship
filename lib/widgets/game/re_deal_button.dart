import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';

class ReDealButton extends StatelessWidget {
  const ReDealButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (!state.areWeJudge &&
            !state.haveWeSubmittedResponse &&
            (state.currentPlayer.prizes?.length ?? 0) > 0) {
          return IconButton(
            icon: Icon(MdiIcons.cardsVariant),
            tooltip: 'Re-deal your hand',
            color: Colors.white,
            onPressed: () async {
              final gameContext = context.read<GameRepository>();
              var result = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Deal new hand?'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      content: RichText(
                        text: TextSpan(
                          text: 'Spend ',
                          children: [
                            TextSpan(
                                text:
                                    '1 of ${state.currentPlayer.prizes?.length} prize cards',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            const TextSpan(text: ' to deal you a new hand?'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: Text(
                            'DEAL',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  });
              if (result ?? false) {
                // Analytics().logSelectContent(
                //     contentType: 'action', itemId: 'redeal_hand');
                await gameContext.reDealHand(state.game.id);
              }
            },
          );
        } else {
          return Container();
        }
      },
    );
  }
}
