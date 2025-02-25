import 'dart:async';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
// import 'package:apps_against_fellowship/config/config.dart';
// import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // print('HOME');
          // if (state.joiningGame != '' || state.isLoading) {
          //   print('loading');
          //   print('joining: ${state.joinedGame}');
          //   print('loading: ${state.isLoading}');
          // } else {
          //   print('normal');
          //   print('joining: ${state.joinedGame}');
          //   print('loading: ${state.isLoading}');
          // }
          _handleError(context, state);
          // if (state.error != '') {
          //   print('ERROR: ${state.error}');

          //   SchedulerBinding.instance.addPostFrameCallback((_) {
          //     // errorTimer = Timer(
          //     //   const Duration(seconds: 3),
          //     //   () {
          //     //     context.read<HomeBloc>().add(
          //     //           RefreshHome(),
          //     //         );
          //     //   },
          //     // );
          //   });
          // }
          _handleJoined(state);
          // print(state);
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
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
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
                                  color: Theme.of(context).colorScheme.surface,
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
                ],
                if (state.isLoading || state.joiningGame != '') ...[
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
                // state.games.isNotEmpty
                //     ? Container(
                //         margin: const EdgeInsets.only(
                //           left: 24,
                //           right: 24,
                //           top: 24,
                //         ),
                //         child: Text(
                //           'Past Games',
                //           style: Theme.of(context)
                //               .textTheme
                //               .displayMedium!
                //               .copyWith(
                //                 color:
                //                     Theme.of(context).colorScheme.surface,
                //                 fontSize: 24,
                //               ),
                //         ),
                //       )
                //     : const SizedBox(),
                // state.games.isNotEmpty
                //     ? Container(
                //         margin: const EdgeInsets.only(
                //           left: 16,
                //         ),
                //         child: Divider(
                //           height: 1,
                //           // color: Colors.white12,
                //           color: Theme.of(context).colorScheme.surface,
                //         ),
                //       )
                //     : const SizedBox(),
                // state.games.isNotEmpty
                //     ? Expanded(
                //         child: ListView.builder(
                //           padding: const EdgeInsets.symmetric(
                //             vertical: 8,
                //           ),
                //           itemCount: state.games.length,
                //           itemBuilder: (context, index) {
                //             var game = state.games[index];
                //             var isLeavingGame =
                //                 game.id == state.leavingGame.id;
                //             return PastGame(
                //               game: game,
                //               isLeavingGame: isLeavingGame,
                //             );
                //           },
                //         ),
                //       )
                //     : const SizedBox(),
                // const SizedBox(height: 50),
                // TextButton(
                //   onPressed: () async {
                //     // context.read<AuthBloc>().add(
                //     //       SignOut(),
                //     //     );
                //     try {
                //       await FirebaseFunctions.instance
                //           .httpsCallable('testCallFunction')
                //           .call(
                //         {
                //           'email': 'dan@kheadies.com',
                //           'message': 'This works!',
                //         },
                //       );

                //       if (context.mounted) {
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           const SnackBar(
                //             duration: Duration(seconds: 3),
                //             content: Text('Success!'),
                //           ),
                //         );
                //       }
                //     } on FirebaseFunctionsException catch (error) {
                //       print('error: $error');
                //     } catch (err) {
                //       print('err: $err');
                //     }
                //   },
                //   child: const Text('Test Function'),
                // ),
              ],
            ),
          );
        },
      ),
    );
    // return ScreenWrapper(
    //   screen: 'Home',
    //   hideAppBar: true,
    //   child: BlocProvider(
    //     create: (context) => HomeBloc(
    //       gameRepository: context.read<GameRepository>(),
    //       userBloc: context.read<UserBloc>(),
    //     ),
    //     child: MultiBlocListener(
    //       listeners: [
    //         // Error Listener
    //         BlocListener<HomeBloc, HomeState>(
    //           listenWhen: (previous, current) =>
    //               previous.error != current.error && current.error != '',
    //           listener: (context, state) {
    //             if (state.error != '') {
    //               ScaffoldMessenger.of(context)
    //                 ..removeCurrentSnackBar()
    //                 ..showSnackBar(
    //                   SnackBar(
    //                     backgroundColor: Colors.redAccent,
    //                     content: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text(
    //                           state.error,
    //                         ),
    //                         const Icon(
    //                           Icons.error,
    //                         )
    //                       ],
    //                     ),
    //                   ),
    //                 );
    //             }
    //           },
    //         ),
    //         // // Joined Game listener that opens a 'joined' game
    //         // BlocListener<HomeBloc, HomeState>(
    //         //   listenWhen: (previous, current) =>
    //         //       previous.joinedGame.id != current.joinedGame.id,
    //         //   listener: (context, state) {
    //         //     if (state.joinedGame != null) {
    //         //       context.goNamed('game');
    //         //     }
    //         //   },
    //         // ),
    //         // Handled in HomeBloc sub
    //         // BlocListener<UserBloc, UserState>(
    //         //     listenWhen: (previous, current) =>
    //         //         previous.user != current.user,
    //         //     listener: (context, state) {
    //         //       print('triggered user bloc on home');
    //         //       if (state.userStatus == UserStatus.loaded) {
    //         //         print('update home via user');
    //         //         context.read<HomeBloc>().add(
    //         //               UserUpdatedViaHome(user: state.user),
    //         //             );
    //         //       }
    //         //     }),
    //       ],
    //       child: BlocBuilder<HomeBloc, HomeState>(
    //         builder: (context, state) {
    //           print('HOME');
    //           // print(state);
    //           return Padding(
    //             padding: const EdgeInsets.only(
    //               bottom: 10,
    //               top: 60,
    //             ),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Container(
    //                   width: double.infinity,
    //                   margin: const EdgeInsets.only(
    //                     left: 24,
    //                     right: 24,
    //                   ),
    //                   child: Text(
    //                     // TODO: convert for internationalization
    //                     'Apps Against Fellowship',
    //                     style:
    //                         Theme.of(context).textTheme.headlineLarge!.copyWith(
    //                               color: Theme.of(context).colorScheme.surface,
    //                             ),
    //                   ),
    //                 ),
    //                 Container(
    //                   margin: const EdgeInsets.only(
    //                     left: 24,
    //                     right: 24,
    //                     top: 32,
    //                   ),
    //                   child: Wrap(
    //                     alignment: WrapAlignment.start,
    //                     direction: Axis.horizontal,
    //                     spacing: 12,
    //                     runSpacing: 16,
    //                     children: [
    //                       const SettingsWidget(),
    //                       const UserWidget(),
    //                       HomeOutlineButton(
    //                         icon: Icon(
    //                           MdiIcons.gamepad,
    //                           color: Theme.of(context).colorScheme.primary,
    //                         ),
    //                         text: 'New Game',
    //                         onTap: state.joiningGame == ''
    //                             ? () {
    //                                 // Analytics > start game
    //                                 // Push Notifications check permissions
    //                                 context.goNamed('createGame');
    //                               }
    //                             : null,
    //                       ),
    //                       JoinGameWidget(
    //                         state: state,
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                 // Note: UX alt: show Joining Game loading w/ widgets here
    //                 // Present error message
    //                 if (!state.isLoading && state.joiningGame == '') ...[
    //                   state.games.isNotEmpty
    //                       ? Container(
    //                           margin: const EdgeInsets.only(
    //                             left: 24,
    //                             right: 24,
    //                             top: 24,
    //                           ),
    //                           child: Text(
    //                             'Past Games',
    //                             style: Theme.of(context)
    //                                 .textTheme
    //                                 .displayMedium!
    //                                 .copyWith(
    //                                   color:
    //                                       Theme.of(context).colorScheme.surface,
    //                                   fontSize: 24,
    //                                 ),
    //                           ),
    //                         )
    //                       : const SizedBox(),
    //                   state.games.isNotEmpty
    //                       ? Container(
    //                           margin: const EdgeInsets.only(
    //                             left: 16,
    //                           ),
    //                           child: Divider(
    //                             height: 1,
    //                             // color: Colors.white12,
    //                             color: Theme.of(context).colorScheme.surface,
    //                           ),
    //                         )
    //                       : const SizedBox(),
    //                   state.games.isNotEmpty
    //                       ? Expanded(
    //                           child: ListView.builder(
    //                             padding: const EdgeInsets.symmetric(
    //                               vertical: 8,
    //                             ),
    //                             itemCount: state.games.length,
    //                             itemBuilder: (context, index) {
    //                               var game = state.games[index];
    //                               var isLeavingGame =
    //                                   game.id == state.leavingGame.id;
    //                               return PastGame(
    //                                 game: game,
    //                                 isLeavingGame: isLeavingGame,
    //                               );
    //                             },
    //                           ),
    //                         )
    //                       : const SizedBox(),
    //                 ],
    //                 if (state.isLoading || state.joiningGame != '') ...[
    //                   Expanded(
    //                     child: Center(
    //                       child: CircularProgressIndicator(),
    //                     ),
    //                   ),
    //                 ],
    //                 // state.games.isNotEmpty
    //                 //     ? Container(
    //                 //         margin: const EdgeInsets.only(
    //                 //           left: 24,
    //                 //           right: 24,
    //                 //           top: 24,
    //                 //         ),
    //                 //         child: Text(
    //                 //           'Past Games',
    //                 //           style: Theme.of(context)
    //                 //               .textTheme
    //                 //               .displayMedium!
    //                 //               .copyWith(
    //                 //                 color:
    //                 //                     Theme.of(context).colorScheme.surface,
    //                 //                 fontSize: 24,
    //                 //               ),
    //                 //         ),
    //                 //       )
    //                 //     : const SizedBox(),
    //                 // state.games.isNotEmpty
    //                 //     ? Container(
    //                 //         margin: const EdgeInsets.only(
    //                 //           left: 16,
    //                 //         ),
    //                 //         child: Divider(
    //                 //           height: 1,
    //                 //           // color: Colors.white12,
    //                 //           color: Theme.of(context).colorScheme.surface,
    //                 //         ),
    //                 //       )
    //                 //     : const SizedBox(),
    //                 // state.games.isNotEmpty
    //                 //     ? Expanded(
    //                 //         child: ListView.builder(
    //                 //           padding: const EdgeInsets.symmetric(
    //                 //             vertical: 8,
    //                 //           ),
    //                 //           itemCount: state.games.length,
    //                 //           itemBuilder: (context, index) {
    //                 //             var game = state.games[index];
    //                 //             var isLeavingGame =
    //                 //                 game.id == state.leavingGame.id;
    //                 //             return PastGame(
    //                 //               game: game,
    //                 //               isLeavingGame: isLeavingGame,
    //                 //             );
    //                 //           },
    //                 //         ),
    //                 //       )
    //                 //     : const SizedBox(),
    //                 // const SizedBox(height: 50),
    //                 // TextButton(
    //                 //   onPressed: () async {
    //                 //     // context.read<AuthBloc>().add(
    //                 //     //       SignOut(),
    //                 //     //     );
    //                 //     try {
    //                 //       await FirebaseFunctions.instance
    //                 //           .httpsCallable('testCallFunction')
    //                 //           .call(
    //                 //         {
    //                 //           'email': 'dan@kheadies.com',
    //                 //           'message': 'This works!',
    //                 //         },
    //                 //       );

    //                 //       if (context.mounted) {
    //                 //         ScaffoldMessenger.of(context).showSnackBar(
    //                 //           const SnackBar(
    //                 //             duration: Duration(seconds: 3),
    //                 //             content: Text('Success!'),
    //                 //           ),
    //                 //         );
    //                 //       }
    //                 //     } on FirebaseFunctionsException catch (error) {
    //                 //       print('error: $error');
    //                 //     } catch (err) {
    //                 //       print('err: $err');
    //                 //     }
    //                 //   },
    //                 //   child: const Text('Test Function'),
    //                 // ),
    //               ],
    //             ),
    //           );
    //         },
    //       ),
    //     ),
    //   ),
    // );
  }

  void _handleJoined(HomeState state) {
    if (state.joinedGame != null && state.joinedGame != Game.emptyGame) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        context.goNamed(
          'game',
          extra: state.joinedGame,
        );
      });
    }
  }

  // Future<void> _handleError(
  //   AuthState state,
  //   BuildContext context,
  // ) async {
  //   String errorMsg = state.errorMessage!
  //       .replaceAll('Exception: ', '')
  //       .replaceAll(RegExp('\\[.*?\\]'), '');

  //   await Future.delayed(const Duration(milliseconds: 300));

  //   if (context.mounted) {
  //     ScaffoldMessenger.of(context)
  //       ..removeCurrentSnackBar()
  //       ..showSnackBar(
  //         SnackBar(
  //           content: Text(errorMsg),
  //           duration: const Duration(milliseconds: 4200),
  //         ),
  //       );

  //     context.read<AuthBloc>().add(
  //           ResetError(),
  //         );
  //   }
  // }

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

      // SchedulerBinding.instance.addPostFrameCallback((_) {
      //   ScaffoldMessenger.of(context)
      //     ..removeCurrentSnackBar()
      //     ..showSnackBar(
      //       SnackBar(
      //         // backgroundColor: whiteUltimate, // TODO
      //         duration: const Duration(seconds: 3),
      //         content: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Text(
      //               state.error,
      //             ),
      //             Icon(
      //               Icons.error,
      //             )
      //           ],
      //         ),
      //       ),
      //     );
      //   errorTimer = Timer(
      //     const Duration(seconds: 3),
      //     () {
      //       context.read<HomeBloc>().add(
      //             RefreshHome(),
      //           );
      //     },
      //   );
      // });
    }
  }
}
