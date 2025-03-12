import 'dart:async';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showToS = false;
  late Timer errorTimer;
  late Timer webNavTimer;
  late WebViewController webViewCont;

  @override
  void initState() {
    super.initState();

    errorTimer = Timer(Duration.zero, () {});
    webNavTimer = Timer(Duration.zero, () {});

    if (!kIsWeb) {
      _initializeToS();
    }
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
          _handleError(context, state);
          _handleGame(context, state);
          _handleToS(context, context.read<UserBloc>().state);
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

  void _handleGame(
    BuildContext context,
    HomeState state,
  ) {
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
  }

  Future<void> _handleToS(
    BuildContext context,
    UserState state,
  ) async {
    if (state.user != User.emptyUser && !state.user.acceptedTerms && !showToS) {
      setState(() {
        showToS = true;
      });

      bool acceptsToS = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          if (kIsWeb) {
            // setState(() {
            //   kWebNavToToS = true;
            // });
            webNavTimer = Timer(
              Duration(milliseconds: 1500),
              () async {
                // setState(() {
                //   kWebHasNavToToS = true;
                // });
                final Uri url = Uri.parse(
                  'https://apps-against-fellowship.web.app/tos.html',
                );
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
            );
          }
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Terms of Service',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.surface,
                  ),
            ),
            content: kIsWeb
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Do you agree to the following Terms of Service?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const CircularProgressIndicator(),
                    ],
                  )
                : WebViewWidget(
                    controller: webViewCont,
                  ),
            actions: [
              TextButton(
                child: Text(
                  'DECLINE',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(
                  'ACCEPT',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (acceptsToS) {
        if (context.mounted) {
          context.read<UserBloc>().add(
                UpdateUser(
                  updateFirebase: true,
                  user: state.user.copyWith(
                    acceptedTerms: true,
                  ),
                ),
              );
        } else {
          print('TOS error; context not mounted');
        }
      }

      setState(() {
        showToS = false;
      });
    }
  }

  void _initializeToS() {
    webViewCont = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //   return NavigationDecision.prevent;
            // }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://apps-against-fellowship.web.app/tos.html',
        ),
      );
  }

  // void registerViewFactory() {
  //   // Register a custom view factory for HtmlElementView
  //   // This view factory creates an iframe element to display HTML content
  //   web.platformViewRegistry.registerViewFactory(
  //     'plotly-chart-html',
  //     (int viewId) {
  //       // Create an iframe element
  //       var element = html.IFrameElement();
  //       // Set the source of the iframe to your HTML file
  //       element.src = 'path/to/your/html/file.html';
  //       // Allow iframe to resize according to its content
  //       element.style.border = 'none';
  //       element.style.width = '100%';
  //       element.style.height = '100%';
  //       return element;
  //     },
  //   );
  // }
}
