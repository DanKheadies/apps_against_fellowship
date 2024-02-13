import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/screens/screens.dart';

class GameScreen extends StatelessWidget {
  final Game game;

  const GameScreen({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(
        authRepository: context.read<AuthRepository>(),
        gameRepository: context.read<GameRepository>(),
        initialGame: game,
        userBloc: context.read<UserBloc>(),
      )..add(
          Subscribe(
            gameId: game.id,
          ),
        ),
      child: BlocBuilder<GameBloc, GameState>(
        buildWhen: (previous, current) {
          return previous.game.gameStatus != current.game.gameStatus ||
              (previous.game.gameStatus == GameStatus.waitingRoom &&
                  current.game.gameStatus == GameStatus.waitingRoom &&
                  previous.gameStateStatus != GameStateStatus.submitting &&
                  current.gameStateStatus != GameStateStatus.submitting);
        },
        builder: (context, state) {
          if (state.game.gameStatus == GameStatus.waitingRoom) {
            return state.gameStateStatus == GameStateStatus.submitting
                ? StartingRoomScreen(state)
                : WaitingRoomScreen();
          } else if (state.game.gameStatus == GameStatus.starting) {
            return StartingRoomScreen(state);
          } else if (state.game.gameStatus == GameStatus.inProgress) {
            return GamePlayScreen(state);
          } else if (state.game.gameStatus == GameStatus.completed) {
            return CompletedGameScreen();
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
