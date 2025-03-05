import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
// import 'package:logger/logger.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PastGame extends StatelessWidget {
  final bool isLeavingGame;
  final UserGame game;

  const PastGame({
    super.key,
    required this.game,
    required this.isLeavingGame,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(game.id),
      background: buildBackground(context),
      confirmDismiss: (_) => confirmDismiss(context),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        // Analytics > past game leave
        context.read<HomeBloc>().add(
              LeaveGame(
                game: game,
              ),
            );
      },
      child: buildListTile(context),
    );
  }

  Future<bool?> confirmDismiss(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Leave game?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          content: Text(
            'Are you sure you want to leave the game ${game.gameId}?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                'LEAVE',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Widget buildBackground(BuildContext context) {
    return Container(
      color: Colors.redAccent[200],
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 16),
            child: Icon(
              MdiIcons.deleteEmpty,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          const Expanded(
            child: SizedBox(),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Icon(
              MdiIcons.deleteEmpty,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListTile(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Text(
        game.gameId,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
      subtitle: Text(
        isLeavingGame ? 'Leaving...' : game.gameStatus.label,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
      trailing: isLeavingGame
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            )
          : Text(
              game.joinedAt != null
                  ? DateFormat('MMM d @ HH:mm').format(game.joinedAt!.toLocal())
                  : '???',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.surface,
                  ),
            ),
      onTap: game.gameStatus == GameStatus.inProgress ||
              game.gameStatus == GameStatus.waitingRoom
          ? () {
              context.read<GameBloc>().add(
                    OpenGame(
                      gameId: game.id,
                      user: context.read<UserBloc>().state.user,
                    ),
                  );
              context.goNamed('game');
            }
          : () {},
    );
  }
}
