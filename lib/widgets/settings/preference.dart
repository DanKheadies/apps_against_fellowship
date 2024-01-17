import 'package:flutter/material.dart';

class Preference extends StatelessWidget {
  final Color? titleColor;
  final FontWeight? titleWeight;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? icon;
  final Widget? trailing;

  const Preference({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.subtitle,
    this.titleColor,
    this.titleWeight,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color:
                  titleColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: titleWeight ?? FontWeight.normal,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
            )
          : null,
      leading: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        child: icon ??
            const SizedBox(
              height: 24,
              width: 24,
            ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
