import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/screens/screens.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameScreen extends StatefulWidget {
  final Game game;

  const GameScreen({
    super.key,
    required this.game,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();

    context.read<GameBloc>().add(
          GameUpdated(
            game: widget.game,
          ),
        );
    context.read<GameBloc>().add(
          Subscribe(
            gameId: widget.game.id,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      screen: 'Game',
      hideAppBar: true,
      child: BlocBuilder<GameBloc, GameState>(
        buildWhen: (previous, current) {
          return previous.game.gameStatus != current.game.gameStatus ||
              (previous.game.gameStatus == GameStatus.waitingRoom &&
                  current.game.gameStatus == GameStatus.waitingRoom &&
                  previous.gameStateStatus != GameStateStatus.submitting &&
                  current.gameStateStatus != GameStateStatus.submitting);
        },
        builder: (context, state) {
          if (state.game.id == '') {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state.game.gameStatus == GameStatus.waitingRoom) {
            return state.gameStateStatus == GameStateStatus.submitting
                ? StartingRoomScreen(state: state)
                : const WaitingRoomScreen();
          } else if (state.game.gameStatus == GameStatus.starting) {
            return StartingRoomScreen(state: state);
          } else if (state.game.gameStatus == GameStatus.inProgress) {
            return GamePlayScreen(state: state);
          } else if (state.game.gameStatus == GameStatus.completed) {
            return const CompletedGameScreen();
          } else {
            return const SizedBox();
          }
        },
      ),
    );
    // return BlocProvider(
    //   create: (context) => GameBloc(
    //     authRepository: context.read<AuthRepository>(),
    //     gameRepository: context.read<GameRepository>(),
    //     // initialGame: game,
    //     userBloc: context.read<UserBloc>(),
    //   )..add(
    //       Subscribe(
    //         gameId: game.id,
    //       ),
    //     ),
    //   child: BlocBuilder<GameBloc, GameState>(
    //     buildWhen: (previous, current) {
    //       print('prev status: ${previous.game.gameStatus}');
    //       print('current status: ${previous.game.gameStatus}');
    //       return previous.game.gameStatus != current.game.gameStatus ||
    //           (previous.game.gameStatus == GameStatus.waitingRoom &&
    //               current.game.gameStatus == GameStatus.waitingRoom &&
    //               previous.gameStateStatus != GameStateStatus.submitting &&
    //               current.gameStateStatus != GameStateStatus.submitting);
    //     },
    //     builder: (context, state) {
    //       print('bloc builder');
    //       print(state.gameStatus);
    //       print(state.gameStateStatus);
    //       if (state.game.gameStatus == GameStatus.waitingRoom) {
    //         return state.gameStateStatus == GameStateStatus.submitting
    //             ? StartingRoomScreen(state: state)
    //             : const WaitingRoomScreen();
    //       } else if (state.game.gameStatus == GameStatus.starting) {
    //         return StartingRoomScreen(state: state);
    //       } else if (state.game.gameStatus == GameStatus.inProgress) {
    //         return GamePlayScreen(state: state);
    //       } else if (state.game.gameStatus == GameStatus.completed) {
    //         return const CompletedGameScreen();
    //       } else {
    //         return const SizedBox();
    //       }
    //     },
    //   ),
    // );
  }
}
