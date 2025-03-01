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
        print('build judge bar');
        // print(state);
        // print(state.)
        // TODO: state.currentJudge is null atm; not sure if game_state.dart
        // is setting it correctly / at all
        print(state.players.length);
        print('judgeId: ${state.game.turn?.judgeId}');
        if (state.players.isNotEmpty) {
          print('we have players..');
          var judge = state.currentJudge;
          print('judge: $judge');
          var hasDownvoted = state.downvotes.contains(state.userId);
          print(hasDownvoted);
          if (judge != Player.emptyPlayer) {
            return _buildHeader(
              context,
              judge,
              hasDownvoted: hasDownvoted,
            );
          } else {
            return Container(height: 72);
          }
        } else {
          return Container(height: 72);
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context, Player player,
      {bool hasDownvoted = false}) {
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
          IconButton(
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
                    context.read<GameBloc>().add(DownvotePrompt());
                  }
                : null,
          )
        ],
      ),
    );
  }

  Widget _buildJudgeAvatar(BuildContext context, Player player) {
    return Container(
      width: 52,
      padding: const EdgeInsets.only(left: 12),
      child: PlayerCircleAvatar(player: player),
    );
  }
}
