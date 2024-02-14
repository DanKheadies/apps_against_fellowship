import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
// import 'package:apps_against_fellowship/config/config.dart';
// import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      screen: 'Home',
      hideAppBar: true,
      // actions: [
      //   IconButton(
      //     onPressed: () {
      //       context.read<AuthBloc>().add(
      //             SignOut(),
      //           );
      //     },
      //     icon: const Icon(
      //       Icons.exit_to_app,
      //     ),
      //   ),
      // ],
      child: BlocProvider(
        create: (context) => HomeBloc(
            // gameRepository: context.read<GameRepository>(),
            // userRepository: context.read<UserRepository>(),
            )
          ..add(HomeStarted()),
        child: MultiBlocListener(
          listeners: [
            // Error Listener
            BlocListener<HomeBloc, HomeState>(
              listenWhen: (previous, current) =>
                  previous.error != current.error && current.error != '',
              listener: (context, state) {
                if (state.error != '') {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.error,
                            ),
                            const Icon(
                              Icons.error,
                            )
                          ],
                        ),
                      ),
                    );
                }
              },
            ),
            // // Joined Game listener that opens a 'joined' game
            // BlocListener<HomeBloc, HomeState>(
            //   listenWhen: (previous, current) =>
            //       previous.joinedGame.id != current.joinedGame.id,
            //   listener: (context, state) {
            //     if (state.joinedGame != null) {
            //       context.goNamed('game');
            //     }
            //   },
            // ),
          ],
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
                                    // context.goNamed('createGame');
                                    print('TODO: go to create game screen');
                                  }
                                : null,
                          ),
                          JoinGameWidget(
                            state: state,
                          ),
                        ],
                      ),
                    ),
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
                              // color: Colors.white12,
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
                    // const SizedBox(height: 50),
                    // TextButton(
                    //   onPressed: () {
                    //     context.read<AuthBloc>().add(
                    //           SignOut(),
                    //         );
                    //   },
                    //   child: const Text('Sign Out'),
                    // ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
