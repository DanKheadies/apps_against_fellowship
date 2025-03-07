import 'package:flutter/material.dart';

class SettingsToggle extends StatelessWidget {
  final String title;
  final VoidCallback? onSelected;
  final Widget icon;

  const SettingsToggle(
    this.title,
    this.icon, {
    super.key,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      onTap: onSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
            const SizedBox(width: 10),
            icon,
          ],
        ),
      ),
    );
  }
}
