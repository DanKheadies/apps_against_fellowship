import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HandCard extends StatelessWidget {
  final ResponseCard card;

  const HandCard({
    super.key,
    required this.card,
  });

  static const textPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: double.maxFinite,
      child: Material(
        color: Theme.of(context).colorScheme.inverseSurface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.onInverseSurface,
            width: 1.0,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        elevation: 4,
        shadowColor: Theme.of(context).colorScheme.surface,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          highlightColor: Theme.of(context).colorScheme.primary.withAlpha(50),
          splashColor: Theme.of(context).colorScheme.primary.withAlpha(50),
          onTap: () {
            // Analytics().logSelectContent(
            //     contentType: 'action', itemId: 'picked_response');
            context.read<GameBloc>().add(
                  PickResponseCard(
                    card: card,
                  ),
                );
          },
          child: Column(
            children: <Widget>[
              _buildText(context, card.text),
              Expanded(
                child: _buildCaptionText(context, card.set),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context, String text) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.all(textPadding),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
      ),
    );
  }

  Widget _buildCaptionText(BuildContext context, String text) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.only(right: textPadding, bottom: 16),
      alignment: Alignment.bottomRight,
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color:
                  Theme.of(context).colorScheme.onInverseSurface.withAlpha(175),
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }
}
