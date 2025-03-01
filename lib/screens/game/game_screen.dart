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
        print(state.game);
        if (state.game.id == '') {
          print('no game id; spin');
          // TODO: empty room only (?); seems to be happening via web
          // Should add a post frame nav or timer to bail; going to add manual
          // for now.
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
        } else if (state.gameStateStatus == GameStateStatus.loading) {
          print('loading...');
          return ScreenWrapper(
            screen: 'Loading Game..',
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state.game.gameStatus == GameStatus.waitingRoom ||
            state.game.gameStatus == GameStatus.starting) {
          print('game waiting / starting..');
          // return StartingRoomScreen(state: state);
          // TODO: merge w/ above
          return const WaitingRoomScreen();
        } else if (state.game.gameStatus == GameStatus.inProgress) {
          print('game in progress');
          return GamePlayScreen(state: state);
        } else if (state.game.gameStatus == GameStatus.completed) {
          print('game complete');
          return const CompletedGameScreen();
        } else {
          print('idk');
          return const SizedBox();
        }
      },
    );
  }
}
