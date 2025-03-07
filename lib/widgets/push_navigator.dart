import 'dart:async';
import 'dart:convert';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// TODO
class PushNavigator extends StatefulWidget {
  final BuildContext context;
  final GameBloc gameBloc;
  final GameRepository gameRepository;
  final UserBloc userBloc;
  final Widget child;

  const PushNavigator({
    super.key,
    required this.context,
    required this.child,
    required this.gameBloc,
    required this.gameRepository,
    required this.userBloc,
  });

  @override
  State<PushNavigator> createState() => _PushNavigatorState();
}

class _PushNavigatorState extends State<PushNavigator> {
  // late GoRouter _goContext;
  // late GameRepository _gameRepository;
  // late GameBloc _gameBloc; // Also hmm...
  // late UserBloc _userBloc; // Hmmm.. repo seems OK. Not sure about bloc.
  StreamSubscription<RemoteMessage>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    print('init push nav');
    // Update: yup, DEF can't initilize these here like this.. At least not
    // GoRouter. Since technically this is all in the Widget / App tree, I
    // should be able to feed in references to everything.. Let's try..
    // _goContext = GoRouter.of(widget.context);
    // _gameBloc = widget.context.read<GameBloc>();
    // _gameRepository = widget.context.read<GameRepository>();
    // _userBloc = widget.context.read<UserBloc>();
    _messageSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('onLaunch()');
      print(JsonEncoder().convert(message));
      if (widget.context.mounted) {
        handleNotificationClick(
          message.data,
          GoRouter.of(widget.context)
              .routeInformationProvider
              .value
              .uri
              .toString(),
        );
      } else {
        print('message sub error; context not mounted');
      }
    });

    // TODO: what did dynamic links provide / why initialize here (?)
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void handleNotificationClick(
    Map<String, dynamic> message,
    String currentRoute,
  ) async {
    print('handling notification click');
    String? gameId = message['gameId'] ?? message['data']['gameId']; // TODO
    if (gameId != null) {
      print('have gameId: $gameId');
      navigateToGame(gameId, currentRoute);
    }
  }

  void navigateToGame(
    String gameId,
    String currentRoute, {
    bool andJoin = false,
  }) async {
    // if (gameId != null && gameId.isNotEmpty) {
    print('navigating to game');
    print(currentRoute);
    if (currentRoute == '/game') {
      print('Game is already in the foreground');
      return;
    }
    try {
      User user = widget
          .userBloc.state.user; // TODO: this will be empty unless Hydrated (?)
      Game game = await widget.gameRepository.getGame(gameId, user);
      if (game != Game.emptyGame &&
          (game.gameStatus == GameStatus.inProgress ||
              game.gameStatus == GameStatus.waitingRoom)) {
        print('we have a game and it\'s going, so lets load up and go');
        /*
         * Neuter the turn winner out of the turn; 
         * otherwise the winner bottom sheet will never show.
         * 
         * TODO: test this is needed
         * We're adding some data by passing on game, which we don't actually
         * handle like this anymore. If anything, what's the workflow to join
         * a game. We should implement that here.
         */
        // if (game.turn != Turn.emptyTurn) {
        //   game = game.copyWith(
        //     turn: Turn(
        //       judgeId: game.turn!.judgeId,
        //       responses: game.turn!.responses,
        //       promptCard: game.turn!.promptCard,
        //       winner: null,
        //     ),
        //   );
        // }
        widget.gameBloc.add(
          OpenGame(
            gameId: game.id,
            user: user,
            fromNav: game.turn != Turn.emptyTurn ? true : null, // if true,
            // will sanitize the turn winner like above but in the bloc
          ),
        );
        print('some how that all worked and we going to game');
        // Note: there are other checks for navigation, but since we don't pass
        // a game object to the screen, we need to handle via bloc. We'll test
        // the UX and address as needed.
        if (widget.context.mounted) {
          widget.context.goNamed('game');
        } else {
          print('nav to game err; context not mounted');
        }
      } else {
        print('Unable to join the Game($gameId)');
      }
    } catch (err) {
      print('nav to game error: $err');
    }
    // }
  }
}
