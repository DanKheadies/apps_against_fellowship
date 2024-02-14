import 'package:flutter/material.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';

class PromptCardView extends StatelessWidget {
  final EdgeInsets? margin;
  final GameState state;
  final Widget child;

  static const textPadding = 20.0;

  const PromptCardView({
    super.key,
    required this.state,
    required this.child,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });
  // : margin = margin ?? const EdgeInsets.symmetric(horizontal: 16);

  @override
  Widget build(BuildContext context) {
    // We only want this block builder to update when the prompt changes
    var prompt = state.game.turn?.winner?.promptCard;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildPromptBackground(
                  context: context,
                  card: prompt!,
                ),
                Column(
                  children: [
                    _buildPromptText(context, state),
                    Expanded(
                      child: child,
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptBackground({
    required BuildContext context,
    required PromptCard card,
  }) {
    return Container(
      margin: margin,
      child: Material(
        color: Colors.black,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        elevation: 4,
        child: Container(
          height: double.maxFinite,
        ),
      ),
    );
  }

  Widget _buildPromptText(BuildContext context, GameState state) {
    return GestureDetector(
      onLongPress: () {
        // Analytics().logSelectContent(
        //     contentType: 'action', itemId: 'view_prompt_source');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.game.turn?.winner?.promptCard.set ?? ''),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: double.maxFinite,
        margin: const EdgeInsets.symmetric(
          vertical: textPadding,
          horizontal: textPadding,
        ).add(margin ?? EdgeInsets.zero),
        child: Text(
          state.lastPromptText,
          // style: context.cardTextStyle(Colors.white),
          // TODO
        ),
      ),
    );
  }
}
