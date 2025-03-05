import 'package:apps_against_fellowship/models/models.dart';
import 'package:flutter/material.dart';

class ResponseCardView extends StatelessWidget {
  final ResponseCard card;
  final Widget? child;

  static const textPadding = 20.0;

  const ResponseCardView({
    super.key,
    required this.card,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Material(
        color: Theme.of(context).colorScheme.inverseSurface,
        shadowColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.onInverseSurface,
            width: 1.0,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        elevation: 4,
        child: Column(
          children: [
            _buildText(context, card.text),
            if (child != null)
              Expanded(
                child: child!,
              ),
          ],
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
}

Widget buildResponseCardStack(
  List<ResponseCard> cards, {
  required Widget lastChild,
}) {
  if (cards.isNotEmpty) {
    var nextCard = cards.first;
    var remaining = cards.sublist(1);

    return ResponseCardView(
      key: ValueKey(nextCard),
      card: nextCard,
      child: remaining.isNotEmpty
          ? buildResponseCardStack(remaining, lastChild: lastChild)
          : lastChild,
    );
  } else {
    return const SizedBox();
  }
}
