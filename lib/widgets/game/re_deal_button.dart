import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ReDealButton extends StatelessWidget {
  const ReDealButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (!state.areWeJudge &&
            !state.haveWeSubmittedResponse &&
            (state.currentPlayer.prizes?.length ?? 0) > 0) {
          if (state.gameStateStatus == GameStateStatus.redealing) {
            return Container(
              padding: const EdgeInsets.all(12),
              child: const CircularProgressIndicator(
                strokeWidth: 3,
              ),
            );
          } else {
            return IconButton(
              icon: Icon(MdiIcons.cardsVariant),
              tooltip: 'Re-deal your hand',
              color: Theme.of(context).colorScheme.onPrimary,
              onPressed: () async {
                var result = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          'Deal new hand?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        content: RichText(
                          text: TextSpan(
                            text: 'Spend ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            children: [
                              TextSpan(
                                  text:
                                      '1 of ${state.currentPlayer.prizes?.length} prize cards',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    fontWeight: FontWeight.bold,
                                  )),
                              TextSpan(
                                text: ' to deal you a new hand?',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
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
                                color: Theme.of(context).colorScheme.primary,
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
                  if (context.mounted) {
                    context.read<GameBloc>().add(
                          ReDealHand(
                            gameDocId: state.game.id,
                            userId: context.read<UserBloc>().state.user.id,
                          ),
                        );
                  } else {
                    print('Re-Deal Hand issue; context not mounted.');
                  }
                }
              },
            );
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
