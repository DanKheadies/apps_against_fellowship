import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class GamePlayScreen extends StatefulWidget {
  final GameState state;

  const GamePlayScreen({
    super.key,
    required this.state,
  });

  @override
  State<StatefulWidget> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      screen: 'Game On',
      hideAppBar: true,
      customBottAppBar: widget.state.players.isNotEmpty
          ? BottomAppBar(
              notchMargin: 8,
              shape: const CircularNotchedRectangle(),
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        color: Theme.of(context).colorScheme.onPrimary,
                        onPressed: () {
                          context.read<HomeBloc>().add(
                                RefreshHome(),
                              );
                          context.goNamed('home');
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 16),
                        child: GameStatusTitle(),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 16, right: 16),
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: const ReDealButton(),
                          ),
                          IconButton(
                            icon: Icon(MdiIcons.accountGroup),
                            color: Theme.of(context).colorScheme.onPrimary,
                            onPressed: () {
                              _showPlayerBottomSheet(context);
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          : null,
      child: BlocListener<GameBloc, GameState>(
        listenWhen: (previous, current) {
          return current.game.turn?.winner != previous.game.turn?.winner;
        },
        listener: (context, state) {
          print('game state update');
          var turnWinner = state.game.turn?.winner;
          print('turnWinner id: ${turnWinner?.playerId}');
          if (turnWinner != null && turnWinner != TurnWinner.emptyTurnWinner) {
            print('gonna show, but prob don\'t have players loaded yet');
            print(state.players.length);
            _showWinnerBottomSheet(context, state);
          }
        },
        child: widget.state.players.isNotEmpty
            ? _buildBody()
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: const Column(
        children: [
          JudgeBar(),
          Expanded(
            child: Stack(
              children: [
                PromptContainer(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 256,
                    child: PlayerResponsePicker(),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showWinnerBottomSheet(BuildContext context, GameState state) {
    // Analytics().logViewItemList(itemCategory: 'turn_winner');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.97,
          builder: (context, scrollController) {
            return GameBottomSheet(
              title: 'Round ${state.game.round - 1}',
              child: TurnWinnerSheet(
                scrollController: scrollController,
                state: state,
                turnWinner: state.game.turn?.winner,
              ),
            );
          },
        );
      },
    );
  }

  void _showPlayerBottomSheet(BuildContext context) {
    // Analytics().logViewItemList(itemCategory: 'players');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.885,
          builder: (context, scrollController) {
            return GameBottomSheet(
              title: "Players",
              actions: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 56,
                  alignment: Alignment.center,
                  child: Text(
                    widget.state.game.gameId,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                )
              ],
              child: PlayerList(
                initialGame: widget.state.game,
                scrollController: scrollController,
              ),
            );
          },
        );
      },
    );
  }
}
