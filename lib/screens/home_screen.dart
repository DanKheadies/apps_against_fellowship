import 'dart:async';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer errorTimer;

  @override
  void initState() {
    errorTimer = Timer(Duration.zero, () {});
    super.initState();
  }

  @override
  void dispose() {
    errorTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      screen: 'Home',
      hideAppBar: true,
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state.joinedGame != null && state.joinedGame != Game.emptyGame) {
            context.read<GameBloc>().add(
                  OpenGame(
                    gameId: state.joinedGame!.id,
                    user: context.read<UserBloc>().state.user,
                  ),
                );
            context.goNamed('game');
          }
          _handleError(context, state);
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
                top: 60,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                    ),
                    child: Text(
                      // TODO: convert for internationalization
                      'Apps Against Fellowship',
                      style:
                          Theme.of(context).textTheme.headlineLarge!.copyWith(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 32,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      direction: Axis.horizontal,
                      spacing: 12,
                      runSpacing: 16,
                      children: [
                        const SettingsWidget(),
                        const UserWidget(),
                        // HomeOutlineButton(
                        //   icon: Icon(
                        //     MdiIcons.testTube,
                        //     color: Theme.of(context).colorScheme.primary,
                        //   ),
                        //   text: 'Test',
                        //   onTap: () => context.read<GameRepository>().testQuery(
                        //         id: '0',
                        //         // ids: [
                        //         //   '1',
                        //         //   '2',
                        //         // ],
                        //         // userId: context.read<UserBloc>().state.user.id,
                        //         // user: {
                        //         //   'id': '',

                        //         // },
                        //       ),
                        // ),
                        HomeOutlineButton(
                          icon: Icon(
                            MdiIcons.gamepad,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          text: 'New Game',
                          onTap: state.joiningGame == ''
                              ? () {
                                  // Analytics > start game
                                  // Push Notifications check permissions
                                  context.goNamed('createGame');
                                }
                              : null,
                        ),
                        JoinGameWidget(
                          state: state,
                        ),
                      ],
                    ),
                  ),
                  // Note: UX alt: show Joining Game loading w/ widgets here
                  // Present error message
                  if (!state.isLoading && state.joiningGame == '') ...[
                    state.games.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.only(
                              left: 24,
                              right: 24,
                              top: 24,
                            ),
                            child: Text(
                              'Past Games',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    fontSize: 24,
                                  ),
                            ),
                          )
                        : const SizedBox(),
                    state.games.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.only(
                              left: 16,
                            ),
                            child: Divider(
                              height: 1,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          )
                        : const SizedBox(),
                    state.games.isNotEmpty
                        ? Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              itemCount: state.games.length,
                              itemBuilder: (context, index) {
                                var game = state.games[index];
                                var isLeavingGame =
                                    game.id == state.leavingGame.id;
                                return PastGame(
                                  game: game,
                                  isLeavingGame: isLeavingGame,
                                );
                              },
                            ),
                          )
                        : const SizedBox(),
                  ],
                  if (state.isLoading || state.joiningGame != '') ...[
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleError(
    BuildContext context,
    HomeState state,
  ) async {
    if (state.error != '') {
      String errMsg =
          state.error.split(']')[1].split('\n')[0].replaceFirst(' ', '');
      await Future.delayed(const Duration(milliseconds: 300));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Text(
                errMsg,
              ),
              // content: Wrap(
              //   direction: Axis.horizontal,
              //   children: [
              //     Icon(
              //       Icons.error,
              //     ),
              //     Text(
              //       errMsg,
              //     ),
              //   ],
              // ),
            ),
          );
        errorTimer = Timer(
          const Duration(seconds: 3),
          () {
            context.read<HomeBloc>().add(
                  RefreshHome(),
                );
          },
        );
      }
    }
  }
}
