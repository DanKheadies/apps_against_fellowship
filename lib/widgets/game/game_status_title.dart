import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';

class GameStatusTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state.areWeJudge) {
          return _buildText(
            context,
            !state.allResponsesSubmitted ? 'Waiting for responses' : 'Judging',
          );
        } else {
          if (state.allResponsesSubmitted) {
            return _buildText(context, 'Waiting for judgement!');
          } else if (state.haveWeSubmittedResponse) {
            return _buildText(context, 'Waiting on other players');
          } else {
            return Container();
          }
        }
      },
    );
  }

  Widget _buildText(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.background,
          ),
    );
  }
}
