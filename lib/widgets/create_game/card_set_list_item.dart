import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/services/services.dart';

class CardSetListItem extends StatelessWidget {
  final bool isSelected;
  final CardSet cardSet;

  const CardSetListItem({
    super.key,
    required this.cardSet,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(CahScrubber.scrub(cardSet.name)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      leading: Checkbox(
        value: isSelected,
        activeColor: Theme.of(context).colorScheme.primary,
        checkColor: Theme.of(context).colorScheme.background,
        onChanged: (value) {
          // Analytics()
          //     .logSelectContent(contentType: 'card_set', itemId: cardSet.name);
          // context.bloc<CreateGameBloc>().add(CardSetSelected(cardSet));
          // print('TODO: select card set');
          context.read<CreateGameBloc>().add(
                CardSetSelected(
                  cardSet: cardSet,
                ),
              );
        },
      ),
      onTap: () {
        // Analytics()
        //     .logSelectContent(contentType: 'card_set', itemId: cardSet.name);
        // context.bloc<CreateGameBloc>().add(CardSetSelected(cardSet));
        // print('TODO: select card set');
        context.read<CreateGameBloc>().add(
              CardSetSelected(
                cardSet: cardSet,
              ),
            );
      },
    );
  }
}
