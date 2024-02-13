import 'package:flutter/material.dart';

import 'package:apps_against_fellowship/models/models.dart';

class PlayerCircleAvatar extends StatelessWidget {
  final Player player;
  final double? radius;

  const PlayerCircleAvatar({
    super.key,
    required this.player,
    this.radius = 20,
  });

  String get playerInitials {
    var splitName = player.name.split(' ');
    if (splitName.isNotEmpty) {
      var nonEmptyCharacters = splitName.where((e) => e.isNotEmpty);
      if (nonEmptyCharacters.isNotEmpty) {
        return nonEmptyCharacters.map((e) => e[0]).join().toUpperCase();
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return player.isRandoCardrissian
        ? CircleAvatar(
            backgroundImage: const AssetImage('assets/rando_cardrissian.png'),
            radius: radius,
          )
        : CircleAvatar(
            radius: radius,
            backgroundImage: player.avatarUrl != null && player.avatarUrl != ''
                ? NetworkImage(player.avatarUrl!)
                : null,
            // backgroundColor: AppColors.primary,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: player.avatarUrl == null || player.avatarUrl != ''
                ? player.name != ''
                    ? Text(
                        playerInitials,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                              // color: Colors.white,
                              color: Theme.of(context).colorScheme.background,
                            ),
                      )
                    : null
                : null,
          );
  }
}
