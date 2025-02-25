import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
// import 'package:apps_against_fellowship/screens/screens.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class CompletedGameScreen extends StatelessWidget {
  const CompletedGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 88),
                child: Text(
                  'Winner',
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: Theme.of(context).canvasColor,
                      ),
                ),
              ),
              _buildAvatar(context, state),
              Container(
                margin: const EdgeInsets.only(top: 24),
                child: Text(
                  state.winner.name != ''
                      ? state.winner.name
                      : Player.defaultName,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Theme.of(context).canvasColor,
                      ),
                ),
              ),
              Expanded(child: Container()),
              if (state.isOurGame)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  width: double.maxFinite,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Analytics().logSelectContent(
                      //     contentType: 'game', itemId: 'create_new_game');
                      // TODO
                      print('TODO: navigation');
                      // Navigator.of(context).pushReplacement(MaterialPageRoute(
                      //     builder: (context) => const CreateGameScreen()));
                    },
                    child: Text(
                      'NEW GAME',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(
                  top: 8,
                  left: 24,
                  right: 24,
                  bottom: 48,
                ),
                width: double.maxFinite,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).canvasColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    // Analytics()
                    //     .logSelectContent(contentType: 'game', itemId: 'quit');
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'QUIT',
                    style: TextStyle(
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, GameState state) {
    Player winner = state.winner;

    return Container(
      width: 156,
      margin: const EdgeInsets.only(top: 48),
      child: Stack(
        children: [
          SizedBox(
            child: PlayerCircleAvatar(
              radius: 78,
              player: winner,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Icon(
                MdiIcons.crown,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          )
        ],
      ),
    );
  }
}
