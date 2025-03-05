import 'dart:async';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/screens/screens.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
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
    return BlocListener<GameBloc, GameState>(
      listener: (context, state) {
        _handleError(context, state);
      },
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          // TODO: would be good to Hydrate GameState so web could refresh page
          // and have data. Would need to check if the wheels churn and Subscribe,
          // et al.
          if (state.game.id == '') {
            // print('no game id; spin');
            return screenWrapper(context);
          } else if (state.game.gameStatus == GameStatus.waitingRoom ||
              state.game.gameStatus == GameStatus.starting) {
            // print('game waiting / starting..');
            return const WaitingRoomScreen();
          } else if (state.game.gameStatus == GameStatus.inProgress) {
            // print('game in progress');
            return GamePlayScreen(state: state);
          } else if (state.game.gameStatus == GameStatus.completed) {
            // print('game complete');
            return const CompletedGameScreen();
          } else if (state.game.gameStatus == GameStatus.gameOver) {
            return const GameOverScreen();
          } else {
            // print('idk');
            return screenWrapper(context);
          }
        },
      ),
    );
  }

  // TODO: add boolean check for "no game id" w/ timer vs "loading / fallback"
  ScreenWrapper screenWrapper(BuildContext context) {
    return ScreenWrapper(
      screen: 'Game',
      hideAppBar: true,
      child: InkWell(
        onTap: () => context.goNamed('home'),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void _handleError(
    BuildContext context,
    GameState state,
  ) {
    if (state.error != '') {
      // print('game screen error: ${state.error}');
      String errMsg =
          state.error.split(']')[1].split('\n')[0].replaceFirst(' ', '');

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              errMsg,
              style: TextStyle(
                color: state.game.gameStatus == GameStatus.inProgress
                    ? Theme.of(context).colorScheme.surfaceTint
                    : Theme.of(context).snackBarTheme.contentTextStyle!.color,
              ),
            ),
            duration: const Duration(seconds: 10),
            backgroundColor: state.game.gameStatus == GameStatus.inProgress
                ? Theme.of(context).colorScheme.surfaceDim
                : Theme.of(context).snackBarTheme.backgroundColor,
            action: errMsg.contains('Game Over')
                ? SnackBarAction(
                    label: 'GGnoRE',
                    onPressed: () {
                      context.goNamed('home');
                    },
                  )
                : null,
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
