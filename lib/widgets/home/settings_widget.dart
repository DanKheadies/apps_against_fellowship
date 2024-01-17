import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:apps_against_fellowship/widgets/widgets.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeOutlineButton(
      icon: Icon(
        Icons.settings,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      text: 'Settings',
      onTap: () {
        // Analytics > action settings
        // Navigator.of(context).push
        context.goNamed('settings');
      },
    );
  }
}
