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
    return ScreenWrapper(
      screen: 'Waiting Room',
      hideAppBar: true,
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              // brightness: Brightness.dark,
              // textTheme: context.theme.textTheme,
              // iconTheme: context.theme.iconTheme,
              title: const Text("Waiting for players"),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => context.goNamed('home'),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                            ),
                            Text(
                              state.game.gameId,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 16, top: 4),
                              // child: ElevatedButton(
                              //   onPressed: () {},
                              //   child: const Text('INVITE'),
                              // ),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  // color: context.primaryColor,
                                  textStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  // textColor: context.primaryColor,
                                  // highlightedBorderColor: context.primaryColor,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.420),
                                  // splashColor:
                                  //     context.primaryColor.withOpacity(0.40),
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  // borderSide:
                                  //     BorderSide(color: context.primaryColor),
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
                                },
                                child: const Text("INVITE"),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              //        actions: [
              //          IconButton(
              //            icon: Icon(Icons.group_add),
              //            onPressed: () async {
              //              var link = await DynamicLinks.createLink(state.game.id);
              //              await Share.share(link.toString());
              //            },
              //          )
              //        ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: state.isOurGame
                ? FloatingActionButton.extended(
                    icon: Icon(MdiIcons.play),
                    label: const Text("START GAME"),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: state.players.length > 2
                        ? () async {
                            // Analytics().logSelectContent(
                            //     contentType: 'action', itemId: 'start_game');
                            context.read<GameBloc>().add(StartGame());
                          }
                        : () {},
                  )
                : null,
            body: BlocListener<GameBloc, GameState>(
              listener: (context, state) {
                if (state.error != '') {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                }
              },
              child: _buildPlayerList(context, state),
            ),
          );
        },
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

  Widget _buildPlayerTile(BuildContext context, Player player, int index) {
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
      BuildContext context, String gameDocumentId) {
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
}
