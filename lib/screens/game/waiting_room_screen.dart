import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class WaitingRoomScreen extends StatelessWidget {
  const WaitingRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        bool isStarting = state.gameStateStatus == GameStateStatus.loading ||
            state.game.gameStatus == GameStatus.starting;

        return ScreenWrapper(
          screen: 'Waiting Room',
          customAppBar: _buildAppBar(isStarting, context, state),
          flaction: state.isOurGame && !isStarting && state.players.length > 2
              ? FloatingActionButton.extended(
                  icon: Icon(MdiIcons.play),
                  label: const Text("START GAME"),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: state.players.length > 2
                      ? () async {
                          // Analytics().logSelectContent(
                          //     contentType: 'action', itemId: 'start_game');
                          context.read<GameBloc>().add(
                                StartGame(),
                              );
                        }
                      : () {},
                )
              : null,
          flactionLocation: FloatingActionButtonLocation.centerFloat,
          child: BlocListener<GameBloc, GameState>(
            listener: (context, state) {
              _handleError(context, state);
            },
            child: isStarting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _buildPlayerList(context, state),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(
    bool isStarting,
    BuildContext context,
    GameState state,
  ) {
    return AppBar(
      title: Text(
        isStarting ? 'Game is starting...' : 'Waiting for players',
      ),
      leading: isStarting
          ? const SizedBox()
          : IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                context.read<HomeBloc>().add(
                      RefreshHome(),
                    );
                context.goNamed('home');
              },
            ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          height: 72,
          padding: const EdgeInsets.only(bottom: 8),
          alignment: Alignment.center,
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 72),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Game ID",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                    ),
                    Text(
                      state.game.gameId,
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                    )
                  ],
                ),
              ),
              isStarting
                  ? const SizedBox()
                  : Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 16, top: 4),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                                textStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.420),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              onPressed: () async {
                                // TODO: invite
                                print('TODO: invite');
                                // Analytics().logShare(
                                //     contentType: 'game',
                                //     itemId: 'invite',
                                //     method: 'dynamic_link');
                                // var link = await DynamicLinks.createLink(
                                //     state.game.id);
                                // await Share.share(link.toString());
                                // context.read<GameBloc>().add(
                                //       ClearPickedResponseCards(),
                                //     );
                              },
                              child: const Text("INVITE"),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the player list which is the only component in this particular tree
  /// that needs to update to the change in game state
  Widget _buildPlayerList(BuildContext context, GameState state) {
    var players = state.players;
    var hasRandoBeenInvitedOrNotOwner =
        state.players.any((element) => element.isRandoCardrissian) ||
            !state.isOurGame;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount:
          hasRandoBeenInvitedOrNotOwner ? players.length : players.length + 1,
      itemBuilder: (context, index) {
        if (index < players.length) {
          var player = players[index];
          return _buildPlayerTile(context, player, index);
        } else {
          return _buildRandoCardrissianInvite(context, state.game.id);
        }
      },
    );
  }

  Widget _buildPlayerTile(
    BuildContext context,
    Player player,
    int index,
  ) {
    var playerName = player.name != '' ? player.name : Player.defaultName;
    if (playerName.trim().isEmpty) {
      playerName = Player.defaultName;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 4,
      ),
      onTap: () {},
      title: Text(
        playerName,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.surface,
            ),
      ),
      leading: PlayerCircleAvatar(
        player: player,
      ),
    );
  }

  Widget _buildRandoCardrissianInvite(
    BuildContext context,
    String gameDocumentId,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        'Invite Rando Cardrissian?',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.surface,
              fontWeight: FontWeight.bold,
            ),
      ),
      leading: const CircleAvatar(
        backgroundImage: AssetImage("assets/images/rando_cardrissian.png"),
      ),
      trailing: Icon(
        MdiIcons.robot,
        color: Theme.of(context).colorScheme.surface,
      ),
      onTap: () async {
        // Analytics().logSelectContent(
        //     contentType: 'players', itemId: 'invite_rando_cardrissian');
        await context
            .read<GameRepository>()
            .addRandoCardrissian(gameDocumentId);
      },
    );
  }

  void _handleError(
    BuildContext context,
    GameState state,
  ) {
    if (state.error != '') {
      String errMsg = state.error.contains(']')
          ? state.error.split(']')[1].split('\n')[0].replaceFirst(' ', '')
          : state.error;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errMsg),
            duration: const Duration(milliseconds: 4200),
          ),
        ).closed.then(
              (value) => context.mounted
                  ? context.read<GameBloc>().add(
                        ClearError(),
                      )
                  : null,
            );
    }
  }
}
