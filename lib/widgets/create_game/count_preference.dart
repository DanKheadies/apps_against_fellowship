import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CountPreference extends StatelessWidget {
  final int value;
  final int max;
  final int min;
  final String title;
  final String? subtitle;
  final void Function(int) onValueChanged;

  const CountPreference({
    super.key,
    required this.value,
    required this.max,
    required this.min,
    required this.title,
    required this.onValueChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: const EdgeInsets.all(8),
            icon: Icon(
              MdiIcons.minus,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              var newValue = (value - 1).clamp(min, max);
              onValueChanged(newValue);
            },
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              value.toString(),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.background,
                  ),
            ),
          ),
          IconButton(
            padding: const EdgeInsets.all(8),
            icon: Icon(
              MdiIcons.plus,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              var newValue = (value + 1).clamp(min, max);
              onValueChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}
