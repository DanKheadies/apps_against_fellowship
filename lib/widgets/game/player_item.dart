import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PlayerItem extends StatelessWidget {
  final Player player;
  final bool isJudge;
  final bool isOwner;
  final bool isSelf;
  final bool isKicking;
  final bool hasDownvoted;

  const PlayerItem({
    super.key,
    required this.player,
    this.isJudge = false,
    this.isOwner = false,
    this.isSelf = false,
    this.isKicking = false,
    this.hasDownvoted = false,
  });

  @override
  Widget build(BuildContext context) {
    if (player.isRandoCardrissian || isSelf) {
      return _buildPlayerListTile(context);
    } else {
      return Dismissible(
        key: const ValueKey('rando-cardrissian_dismissible'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          // Analytics().logSelectContent(contentType: 'action', itemId: 'wave');
          context.read<GameBloc>().add(
                WaveAtPlayer(
                  message: '',
                  playerId: player.id,
                ),
              );
          return false;
        },
        background: Container(
          color: Theme.of(context).colorScheme.primary,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Icon(
            MdiIcons.humanGreeting,
            color: Theme.of(context).canvasColor,
          ),
        ),
        child: _buildPlayerListTile(context),
      );
    }
  }

  Widget _buildPlayerListTile(BuildContext context) {
    var playerName = player.name;
    if (playerName.trim().isEmpty) {
      playerName = Player.defaultName;
    }
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: isOwner ? 8 : 24,
        right: 24,
        top: 4,
        bottom: 4,
      ),
      onTap: () {},
      title: Text(
        playerName,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.surface,
            ),
      ),
      subtitle: isJudge
          ? Text(
              'Judge',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            )
          : null,
      trailing: SizedBox(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasDownvoted)
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: Icon(
                  MdiIcons.thumbDown,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            Icon(
              MdiIcons.cardsPlayingOutline,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            Container(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '${player.prizes?.length ?? 0}',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.surfaceBright,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            )
          ],
        ),
      ),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOwner)
            Container(
              width: kMinInteractiveDimension,
              height: kMinInteractiveDimension,
              margin: const EdgeInsets.only(right: 8),
              child: isKicking
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    )
                  : Visibility(
                      visible: !isSelf,
                      maintainSize: true,
                      maintainState: true,
                      maintainAnimation: true,
                      child: IconButton(
                        icon: Icon(
                          MdiIcons.karate,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          // Kick Player
                          // Analytics().logSelectContent(
                          //     contentType: 'action', itemId: 'kick_player');
                          context.read<GameBloc>().add(
                                KickPlayer(
                                  playerId: player.id,
                                ),
                              );
                        },
                      ),
                    ),
            ),
          PlayerCircleAvatar(player: player),
        ],
      ),
    );
  }
}
