import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PromptContainer extends StatelessWidget {
  const PromptContainer({super.key});

  static const textPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    // We only want this block builder to update when the prompt changes
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) {
        return previous.game.turn?.promptCard != current.game.turn?.promptCard;
      },
      builder: (context, state) {
        var prompt = state.game.turn?.promptCard;
        return Container(
          margin: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              _buildPromptSpecial(context, prompt!),
              Expanded(
                child: Stack(
                  children: [
                    _buildPromptBackground(context),
                    Column(
                      children: [
                        _buildPromptText(context, state),
                        Expanded(
                          child: _buildPromptChild(context),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Here we will build
  Widget _buildPromptChild(
    BuildContext context,
  ) {
    // If Not Judge
    // If winner is null && not submitted response => Show selected cards
    // If winner is null && has submitted response => Show waiting on players tile
    // If winner is not null => Show Winning response cards

    // If Judge
    // If not all responses are submitted => Show waiting on players tile
    // If all responses are submitted => Show Pager of all submissions for the judge to swipe between & Show 'pick winner' button

    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state.areWeJudge) {
          if (state.allResponsesSubmitted) {
            return JudgeDredd(
              state: state,
            );
          } else {
            return WaitingPlayerResponses(
              state: state,
            );
          }
        } else {
          if (state.haveWeSubmittedResponse) {
            return WaitingPlayerResponses(
              state: state,
            );
          } else {
            var responseCardStack = buildResponseCardStack(
              state.selectedCards,
              lastChild: const SizedBox(),
            );
            if (responseCardStack != const SizedBox()) {
              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.down,
                movementDuration: Duration(milliseconds: 0),
                background: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Clear Responses'.toUpperCase(),
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      child: Icon(
                        MdiIcons.chevronTripleDown,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  ],
                ),
                onDismissed: (direction) {
                  // Analytics().logSelectContent(
                  //     contentType: 'action', itemId: 'clear_choices');
                  context.read<GameBloc>().add(ClearPickedResponseCards());
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: responseCardStack,
                ),
              );
            } else {
              return Container();
            }
          }
        }
      },
    );
  }

  Widget _buildPromptSpecial(BuildContext context, PromptCard promptCard) {
    if (promptCard != PromptCard.emptyPromptCard &&
        promptCard.special != PromptSpecial.notSpecial.name) {
      return Container(
        height: 36,
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          promptCard.special.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.surface,
              ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildPromptBackground(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        elevation: 4,
        child: Container(
          height: double.maxFinite,
        ),
      ),
    );
  }

  Widget _buildPromptText(BuildContext context, GameState state) {
    return GestureDetector(
      onLongPress: () {
        // Analytics().logSelectContent(
        //     contentType: 'action', itemId: 'view_prompt_source');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.game.turn?.promptCard.set ?? ""),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: double.maxFinite,
        margin: const EdgeInsets.symmetric(
          vertical: textPadding,
          horizontal: textPadding + 16,
        ),
        child: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            return Text(
              state.currentPromptText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            );
          },
        ),
      ),
    );
  }
}
