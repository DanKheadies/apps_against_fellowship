import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class PlayerResponseCard extends StatelessWidget {
  final bool hasSubmittedResponse;
  final Player player;

  const PlayerResponseCard({
    super.key,
    required this.hasSubmittedResponse,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: PlayerCircleAvatar(
                player: player,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                  top: 8,
                  left: 8,
                  right: 8,
                ),
                child: Text(
                  player.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.topCenter,
                child: hasSubmittedResponse
                    ? Icon(
                        MdiIcons.checkboxMarkedCircleOutline,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 32,
                      )
                    : Icon(
                        MdiIcons.checkboxBlankCircleOutline,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 32,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
