import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';

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
        // color: context.responseCardHandColor,
        color: Colors.red,
        shape: const RoundedRectangleBorder(
          side: BorderSide(
            // color: context.responseBorderColor,
            color: Colors.blue,
            width: 1.0,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          // highlightColor: AppColors.primary.withOpacity(0.26),
          highlightColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.26),
          // splashColor: AppColors.primary.withOpacity(0.26),
          splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.26),
          onTap: () {
            // Analytics().logSelectContent(
            //     contentType: 'action', itemId: 'picked_response');
            context.read<GameBloc>().add(PickResponseCard(card: card));
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
        // style: context.cardTextStyle(context.colorOnCard),
        // TODO
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
              // color: context.secondaryColorOnCard,
              color: Theme.of(context).colorScheme.background,
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }
}
