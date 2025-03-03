import 'dart:ui';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PlayerResponsePicker extends StatefulWidget {
  const PlayerResponsePicker({super.key});

  @override
  PlayerResponsePickerState createState() => PlayerResponsePickerState();
}

class PlayerResponsePickerState extends State<PlayerResponsePicker> {
  final PageController _pageController = PageController(
    viewportFraction: 0.945,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        // Determine if we need to show the response picker, or to hide this part
        if (!state.areWeJudge && !state.haveWeSubmittedResponse) {
          // Get the player's current hand, omitting any card's they MAY have submitted
          var hand = state.currentHand.reversed.toList();
          return Stack(
            children: <Widget>[
              AnimatedOpacity(
                opacity:
                    state.gameStateStatus == GameStateStatus.submitting ? 0 : 1,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: PageView.builder(
                  controller: _pageController,
                  scrollBehavior: const ScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  itemCount: hand.length,
                  itemBuilder: (context, index) {
                    var card = hand[index];
                    return HandCard(
                      key: ValueKey(card),
                      card: card,
                    );
                  },
                ),
              ),
              state.gameStateStatus == GameStateStatus.submitting
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        child: _buildSubmittingWidget(context),
                      ),
                    )
                  : const SizedBox(),
              state.selectCardsMeetPromptRequirement &&
                      state.gameStateStatus != GameStateStatus.submitting
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        child: _buildSubmitCardsButton(context),
                      ),
                    )
                  : const SizedBox(),
            ],
          );
        }
        return Container();
      },
    );
  }

  Widget _buildSubmittingWidget(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: const StadiumBorder(),
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
        disabledBackgroundColor: Theme.of(context).colorScheme.surfaceDim,
      ),
      onPressed: null,
      icon: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.surfaceTint,
          ),
        ),
      ),
      label: Container(
        margin: const EdgeInsets.only(left: 8, right: 20),
        child: Text(
          'SUBMITTING...',
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                // color: AppColors.colorOnPrimary,
                color: Theme.of(context).colorScheme.surfaceTint,
                letterSpacing: 1,
              ),
        ),
      ),
    );
  }

  Widget _buildSubmitCardsButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        shape: const StadiumBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () async {
        // Analytics().logSelectContent(
        //     contentType: 'action', itemId: 'submit_responses');
        context.read<GameBloc>().add(SubmitResponses());
      },
      icon: Icon(
        MdiIcons.uploadMultiple,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      label: Container(
        margin: const EdgeInsets.only(left: 8, right: 20),
        child: Text(
          'SUBMIT RESPONSE',
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: Theme.of(context).scaffoldBackgroundColor,
                letterSpacing: 1,
              ),
        ),
      ),
    );
  }
}
