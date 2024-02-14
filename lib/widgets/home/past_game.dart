import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
// import 'package:apps_against_fellowship/repositories/repositories.dart';

class PastGame extends StatelessWidget {
  final bool isLeavingGame;
  final UserGame game;

  const PastGame({
    super.key,
    required this.game,
    required this.isLeavingGame,
  });

  Future<bool?> confirmDismiss(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Leave game?'),
          content: Text('Are you sure you want to leave the game ${game.gid}?'),
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

  void openGame(BuildContext context) async {
    // Analytics > past game open
    try {
      print('TODOs: game repo and nav');
      // TODO: game repo
      // var existingGame = await context.read<GameRepository>().getGame(game.id);
      // TODO: go router
      // Navigator.of(context).push(GamePageRoute(existingGame));
    } catch (err) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('$err'),
          ),
        );
    }
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
              color: Theme.of(context).colorScheme.background,
            ),
          ),
          const Expanded(
            child: SizedBox(),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Icon(
              MdiIcons.deleteEmpty,
              color: Theme.of(context).colorScheme.background,
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
        game.gid,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
      subtitle: Text(
        isLeavingGame ? 'Leaving...' : 'TODO game state', // game.state.label,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.white60,
            ),
      ),
      trailing: isLeavingGame
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            )
          : Text(
              // DateTime.parse(game.joinedAt),
              'TODO joinedAt',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white54,
                  ),
            ),
      // onTap: game.state == GameState.inProgress ||
      //         game.state == GameState.waitingRoom
      //     ? () => openGame(context)
      //     : () {},
      onTap: () => print('TODO game state'),
    );
  }

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
}
