import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          String errMsg = state.error.contains(']')
              ? state.error.split(']')[1].split('\n')[0].replaceFirst(' ', '')
              : state.error;

          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 88),
                child: Text(
                  'Congratulations',
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'You managed to break the game!',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                ),
              ),
              if (state.error != '') ...[
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    errMsg,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                  ),
                ),
              ],
              Expanded(
                child: Container(),
              ),
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
                      context.read<GameBloc>().add(
                            ClearError(),
                          );
                      context.read<HomeBloc>().add(
                            RefreshHome(),
                          );
                      context.goNamed('createGame');
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
                    context.read<HomeBloc>().add(
                          RefreshHome(),
                        );
                    context.goNamed('home');
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
}
