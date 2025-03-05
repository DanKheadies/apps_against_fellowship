import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class JudgeBar extends StatelessWidget {
  const JudgeBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        var judge = state.currentJudge;
        var hasDownvoted = state.downvotes.contains(state.userId);
        if (judge != Player.emptyPlayer) {
          return _buildHeader(
            context,
            judge,
            hasDownvoted: hasDownvoted,
          );
        } else {
          return Container(height: 72);
        }
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Player player, {
    bool hasDownvoted = false,
  }) {
    var playerName = player.name;
    if (playerName.trim().isEmpty) {
      playerName = Player.defaultName;
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      title: Text(playerName),
      subtitle: Text(
        'Current judge',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.surface.withAlpha(175),
            ),
      ),
      leading: _buildJudgeAvatar(context, player),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          context.read<GameBloc>().state.gameStateStatus ==
                  GameStateStatus.waving
              ? CircularProgressIndicator()
              : IconButton(
                  icon: Icon(
                    MdiIcons.humanGreeting,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    // Analytics()
                    //     .logSelectContent(contentType: 'action', itemId: 'wave');
                    context.read<GameBloc>().add(
                          WaveAtPlayer(
                            message: '',
                            playerId: player.id,
                          ),
                        );
                  },
                ),
          Container(
            width: 8,
          ),
          // TODO: show a loading icon when status is "downvoting"
          // Issue: function doesn't have access to GameStateStatus and only
          // GameStatus, so this will need something else.. Could add another
          // status like "loading" or "refreshing" and another GameRefreshingScreen
          // but it's a minor UX thing. Not even sure how long the function takes
          // to fully execute and if the 1-3s is worth the feedback.
          IconButton(
            icon: Icon(
              hasDownvoted ? MdiIcons.thumbDown : MdiIcons.thumbDownOutline,
              color: hasDownvoted
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: !hasDownvoted
                ? () {
                    // Analytics().logSelectContent(
                    //     contentType: 'action', itemId: 'downvote');
                    context.read<GameBloc>().add(
                          DownvotePrompt(),
                        );
                  }
                : null,
          )
        ],
      ),
    );
  }

  Widget _buildJudgeAvatar(BuildContext context, Player player) {
    return InkWell(
      onDoubleTap: () => HelpDialog.openHelpDialog(context),
      child: Container(
        width: 52,
        padding: const EdgeInsets.only(left: 12),
        child: PlayerCircleAvatar(player: player),
      ),
    );
  }
}
