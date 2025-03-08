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
    super.initState();

    errorTimer = Timer(Duration.zero, () {});

    // Note: is this enough to initialize Settings & Audio (?)
    print('settings');
    // context.read<SettingsBloc>().add(InitializeAudio());
    // Update: need to activate some piece of the Bloc, e.g. add() or function
    // call to kick off the initial code.
    // This DOES start the music, but the songs won't continue to loop until
    // I come back here, e.g. the song finishes while I'm on the game screen
    // but it won't loop / go to the next song... Also, still seems to hit the
    // SONG_MAX and times out. I believe I continue to initialize audio when
    // I come back to home, which isn't ideal...
    // Gonna need to consider some UX. I prob could / should initialize in
    // userBloc, which "should" only initialize once being were it is in the
    // widget tree (above MaterialApp.router). The music plays well with the
    // splash screen, but I'll need to provide some kind of UI so users can
    // manage the audio before logging in. I could consider keeping it muted
    // until I get here to home, and then do a check to "play or keep quiet."
    // Either way, there's still the issue of it falling over after playing
    // each song once.
    // TODO
    // Going to avoid initializing here...
    // Going to try initializing with successful AuthSub
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
          bool hasGame =
              state.joinedGame != null && state.joinedGame != Game.emptyGame;
          if (hasGame) {
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
            bool hasGame =
                state.joinedGame != null && state.joinedGame != Game.emptyGame;
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
                  if (hasGame) ...[
                    Expanded(
                      child: Center(
                        child: Icon(
                          Icons.thumb_up_alt_outlined,
                          color: Theme.of(context).colorScheme.surface,
                          size: 50,
                        ),
                      ),
                    ),
                  ],
                  if (!hasGame &&
                      !state.isLoading &&
                      state.joiningGame == '') ...[
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

  void _handleError(
    BuildContext context,
    HomeState state,
  ) {
    if (state.error != '') {
      String errMsg = state.error.contains(']')
          ? state.error.split(']')[1].split('\n')[0].replaceFirst(' ', '')
          : state.error;

      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(errMsg),
          ),
        ).closed.then(
              (value) => context.mounted
                  ? context.read<HomeBloc>().add(
                        RefreshHome(),
                      )
                  : null,
            );
    }
  }
}
