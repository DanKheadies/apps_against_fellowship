import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/screens/screens.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
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
        } else {
          // print('idk');
          return screenWrapper(context);
        }
      },
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
}
