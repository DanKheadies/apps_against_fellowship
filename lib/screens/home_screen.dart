import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
// import 'package:apps_against_fellowship/config/config.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
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
          userRepository: context.read<UserRepository>(),
        )..add(HomeStarted()),
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
                  top: 50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                      ),
                      child: Text(
                        // TODO: convert for internationalization
                        'Apps Against\nFellowship',
                        style:
                            Theme.of(context).textTheme.headlineLarge!.copyWith(
                                  color: Colors.white,
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
                          UserWidget(
                            state: state,
                            onTap: () {
                              // Analytics > action profile
                              context.goNamed('profile');
                            },
                          ),
                          HomeOutlineButton(
                            icon: Icon(
                              Icons.gamepad,
                              color: Theme.of(context).colorScheme.onPrimary,
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
                                    color: Colors.white70,
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
                            child: const Divider(
                              height: 1,
                              color: Colors.white12,
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
                    const SizedBox(height: 50),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              SignOut(),
                            );
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      // child: BlocBuilder<UserBloc, UserState>(
      //   builder: (context, state) {
      //     if (state.userStatus == UserStatus.initial ||
      //         state.userStatus == UserStatus.loading) {
      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      //     if (state.userStatus == UserStatus.loaded) {
      //       return Column(
      //         mainAxisSize: MainAxisSize.max,
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           const Text('Home'),
      //           const SizedBox(
      //             height: 50,
      //             width: double.infinity,
      //           ),
      //           Switch(
      //             value: state.user.acceptedTerms,
      //             activeColor: Colors.red,
      //             onChanged: (value) {
      //               context.read<UserBloc>().add(
      //                     UpdateUser(
      //                       user: state.user.copyWith(
      //                         acceptedTerms: value,
      //                       ),
      //                     ),
      //                   );
      //             },
      //           ),
      //           const SizedBox(
      //             height: 50,
      //             width: double.infinity,
      //           ),
      //           TextButton(
      //             onPressed: () {
      //               context.read<AuthBloc>().add(
      //                     SignOut(),
      //                   );
      //             },
      //             child: const Text('Sign Out'),
      //           ),
      //         ],
      //       );
      //     }
      //     if (state.userStatus == UserStatus.error) {
      //       return const Center(
      //         child: Text('There was an error.'),
      //       );
      //     } else {
      //       return const Center(
      //         child: Text('Something went wrong.'),
      //       );
      //     }
      //   },
      // ),
    );
  }
}
