import 'package:flutter/material.dart';

class PreferenceHeader extends StatelessWidget {
  final bool includeIconSpacing;
  final String title;

  const PreferenceHeader({
    super.key,
    required this.title,
    this.includeIconSpacing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: includeIconSpacing ? 72 : 16,
        right: 16,
      ),
      height: 48,
      width: double.maxFinite,
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
