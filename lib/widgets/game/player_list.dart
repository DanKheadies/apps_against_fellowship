import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class PlayerList extends StatelessWidget {
  final Game initialGame;
  final ScrollController scrollController;

  const PlayerList({
    super.key,
    required this.initialGame,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(
        authRepository: context.read<AuthRepository>(),
        gameRepository: context.read<GameRepository>(),
        userBloc: context.read<UserBloc>(),
      )..add(
          Subscribe(
            gameId: initialGame.id,
          ),
        ),
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          var players = (state.players)
              .where((element) => element.isInactive != true)
              .toList();

          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: players.length,
            itemBuilder: (context, index) {
              var player = players[index];
              var isJudge = player.id == state.game.turn?.judgeId;
              var hasDownvoted = state.downvotes.contains(player.id);

              return PlayerItem(
                player: player,
                isJudge: isJudge,
                isOwner: state.isOurGame,
                isSelf: state.userId == player.id,
                hasDownvoted: hasDownvoted,
              );
            },
          );
        },
      ),
    );
  }
}
