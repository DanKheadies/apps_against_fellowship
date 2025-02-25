import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kt_dart/kt.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocProvider(
        create: (context) => CreateGameBloc(
          cardsRepository: context.read<CardsRepository>(),
          gameRepository: context.read<GameRepository>(),
          userBloc: context.read<UserBloc>(),
        )..add(LoadCreateGame()),
        child: MultiBlocListener(
          listeners: [
            // Error Listener
            BlocListener<CreateGameBloc, CreateGameState>(
              listenWhen: (previous, current) =>
                  current.error != previous.error,
              listener: (context, state) {
                if (state.error != '') {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                }
              },
            ),

            // New Game Listener
            BlocListener<CreateGameBloc, CreateGameState>(
              listenWhen: (previous, current) =>
                  current.createdGame.id != previous.createdGame.id,
              listener: (context, state) {
                // TODO: the UX is slightly off, half second of seeing the lists
                // again before navigating away; rather it keep showing 'loading'
                if (state.createdGame != Game.emptyGame) {
                  // Navigator.of(context)
                  //     .pushReplacement(GamePageRoute(state.createdGame));
                  context.goNamed(
                    'game',
                    extra: state.createdGame,
                  );
                }
              },
            ),
          ],
          child: _buildScaffold(),
        ),
      ),
    );
  }

  Widget _buildScaffold() {
    return BlocBuilder<CreateGameBloc, CreateGameState>(
      builder: (context, state) {
        return state.createGameStatus != CreateGameStatus.loaded
            ? _buildLoading()
            : DefaultTabController(
                length: 2,
                child: ScreenWrapper(
                  screen: 'Create Game',
                  customAppBar: AppBar(
                    title: Text(
                      'New Game',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                    ),
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      onPressed: () {
                        context.goNamed('home');
                      },
                    ),
                    bottom: TabBar(
                      labelColor: Theme.of(context).colorScheme.surface,
                      tabs: const [
                        Tab(text: "CARDS"),
                        Tab(text: "OPTIONS"),
                      ],
                    ),
                  ),
                  customBottAppBar: BottomAppBar(
                    notchMargin: 8,
                    shape: const CircularNotchedRectangle(),
                    child: SizedBox(
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                state.createGameStatus ==
                                        CreateGameStatus.loading
                                    ? "Loading..."
                                    : "${state.totalPrompts} Prompts ${state.totalResponses} Responses",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  flactionLocation: FloatingActionButtonLocation.endDocked,
                  flaction: state.selectedSets.isNotEmpty() &&
                          state.createGameStatus != CreateGameStatus.loading
                      ? FloatingActionButton(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          shape: const CircleBorder(),
                          onPressed: () async {
                            // Analytics().logSelectContent(
                            //     contentType: 'action', itemId: 'create_game');
                            context.read<CreateGameBloc>().add(
                                  CreateGame(),
                                );
                          },
                          child: const Icon(Icons.check),
                        )
                      : null,
                  child: TabBarView(
                    children: [
                      _buildCardSetLists(state),
                      _buildGameOptions(context, state),
                    ],
                  ),
                ),
              );
      },
    );
  }

  Widget _buildCardSetLists(CreateGameState state) {
    return Column(
      children: [
        Expanded(
          child: state.createGameStatus == CreateGameStatus.loading
              ? _buildLoading()
              : _buildList(state.cardSets, state.selectedSets),
        ),
      ],
    );
  }

  Widget _buildGameOptions(BuildContext context, CreateGameState state) {
    return Column(
      children: [
        CountPreference(
          value: state.prizesToWin,
          title: "Prizes to win",
          subtitle: "Choose the number of prize cards it would take to win",
          min: 1,
          max: 15,
          onValueChanged: (value) {
            // Analytics().logSelectContent(
            //     contentType: 'game_option', itemId: 'prizes_to_win');
            context.read<CreateGameBloc>().add(
                  ChangePrizesToWin(
                    prizesToWin: value,
                  ),
                );
          },
        ),
        CountPreference(
          value: state.playerLimit,
          title: "Max # of players",
          subtitle: "Pick the number of players allowed to join your game",
          min: 5,
          max: 30,
          onValueChanged: (value) {
            // Analytics().logSelectContent(
            //     contentType: 'game_option', itemId: 'player_limit');
            context.read<CreateGameBloc>().add(
                  ChangePlayerLimit(
                    playerLimit: value,
                  ),
                );
          },
        ),
        SwitchListTile(
          title: const Text("Enable \"PICK 2\""),
          subtitle: const Text("Allow \"PICK 2\" prompt cards"),
          activeColor: Theme.of(context).colorScheme.primary,
          value: state.pick2Enabled,
          onChanged: (value) {
            // Analytics()
            //     .logSelectContent(contentType: 'game_option', itemId: 'pick2');
            context.read<CreateGameBloc>().add(
                  ChangePick2Enabled(
                    enabled: value,
                  ),
                );
          },
        ),
        SwitchListTile(
          title: const Text("Enable \"DRAW 2, PICK 3\""),
          subtitle: const Text("Allow \"DRAW 2, PICK 3\" prompt cards"),
          activeColor: Theme.of(context).colorScheme.primary,
          value: state.draw2pick3Enabled,
          onChanged: (value) {
            // Analytics().logSelectContent(
            //     contentType: 'game_option', itemId: 'draw2_pick3');
            context.read<CreateGameBloc>().add(
                  ChangeDraw2Pick3Enabled(
                    enabled: value,
                  ),
                );
          },
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildList(KtList<CardSet> sets, KtSet<CardSet> selected) {
    var groupedSets = sets.groupBy((cs) => cs.source);
    var widgets = groupedSets.keys.toList().sortedWith((a, b) {
      var aW = keyWeight(a);
      var bW = keyWeight(b);
      if (aW.compareTo(bW) == 0) {
        return a.compareTo(b);
      } else {
        return aW.compareTo(bW);
      }
    }).flatMap((key) {
      var items = groupedSets.get(key)!.map((cs) => CardSetListItem(
            cardSet: cs,
            isSelected: selected.contains(cs),
          ));
      var allItemsSelected = items.all((i) => i.isSelected);
      return mutableListOf<Widget>(
        HeaderItem(
          title: key,
          isChecked: allItemsSelected ? true : false,
        ),
      )..addAll(items);
    });

    return ListView.builder(
      itemCount: widgets.size,
      itemBuilder: (context, index) => widgets[index],
    );
  }

  int keyWeight(String key) {
    if (key == "Developer") {
      return 0;
    } else if (key == "CAH Main Deck") {
      return 1;
    } else if (key == "CAH Expansions") {
      return 2;
    } else if (key == "CAH Packs") {
      return 3;
    } else if (key.startsWith('CAH Packs/')) {
      return 4;
    } else {
      return 5;
    }
  }
}
