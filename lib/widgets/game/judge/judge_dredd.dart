import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class JudgeDredd extends StatefulWidget {
  final GameState state;

  const JudgeDredd({
    super.key,
    required this.state,
  });

  @override
  JudgeDreddState createState() => JudgeDreddState();
}

class JudgeDreddState extends State<JudgeDredd> {
  final JudgementController controller = JudgementController();

  @override
  void initState() {
    super.initState();

    controller.totalPageCount = widget.state.game.turn?.responses.length ?? 0;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        JudgingPager(
          state: widget.state,
          controller: controller,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 48),
            child: StreamBuilder<int>(
                stream: controller.observePageChanges(),
                builder: (context, snapshot) {
                  var currentPage = snapshot.data ?? 0;
                  var showLeft = currentPage > 0;
                  var showRight = currentPage < controller.totalPageCount - 1;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _buildPageButton(
                          context: context,
                          iconData: Icons.keyboard_arrow_left,
                          isVisible: showLeft),
                      widget.state.gameStateStatus == GameStateStatus.submitting
                          ? _buildPickingWinnerIndicator(context)
                          : const SizedBox(),
                      widget.state.gameStateStatus == GameStateStatus.submitting
                          ? _buildPickWinnerButton(context)
                          : const SizedBox(),
                      _buildPageButton(
                        context: context,
                        iconData: Icons.keyboard_arrow_right,
                        isLeft: false,
                        isVisible: showRight,
                      ),
                    ],
                  );
                }),
          ),
        )
      ],
    );
  }

  Widget _buildPickWinnerButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: const StadiumBorder(),
        // color: AppColors.primary,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () async {
        var currentPlayerResponse = controller.currentPlayerResponse;
        if (currentPlayerResponse.playerId != '') {
          // Analytics()
          //     .logSelectContent(contentType: 'judge', itemId: 'pick_winner');
          print('Winner selected! ${currentPlayerResponse.playerId}');
          context.read<GameBloc>().add(
                PickWinner(
                  winningPlayerId: currentPlayerResponse.playerId,
                ),
              );
        }
      },
      icon: Icon(
        MdiIcons.crown,
        // color: AppColors.colorOnPrimary,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Container(
        margin: const EdgeInsets.only(left: 16, right: 40),
        child: Text(
          'WINNER',
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                // color: AppColors.colorOnPrimary,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1,
              ),
        ),
      ),
    );
  }

  Widget _buildPickingWinnerIndicator(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: const StadiumBorder(),
        // color: AppColors.primary,
        foregroundColor: Theme.of(context).colorScheme.primary,
        // disabledColor: AppColors.primary,
        disabledForegroundColor: Theme.of(context).colorScheme.primary,
      ),
      icon: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      label: Container(
        margin: const EdgeInsets.only(left: 16, right: 40),
        child: Text(
          'SUBMITTING...',
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                // color: AppColors.colorOnPrimary,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1,
              ),
        ),
      ),
      onPressed: null,
    );
  }

  Widget _buildPageButton({
    required BuildContext context,
    required IconData iconData,
    isVisible = true,
    isLeft = true,
  }) {
    return AnimatedOpacity(
      opacity: isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      child: SizedBox(
        height: 48,
        width: 56,
        child: Material(
          // color: AppColors.primary,
          color: Theme.of(context).colorScheme.primary,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: isLeft
                ? const BorderRadius.only(
                    topRight: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    bottomLeft: Radius.circular(28),
                  ),
          ),
          child: InkWell(
            onTap: isVisible
                ? () {
                    if (isLeft) {
                      // Analytics().logSelectContent(
                      //     contentType: 'judge', itemId: 'previous_choice');
                      controller.prevPage();
                    } else {
                      // Analytics().logSelectContent(
                      //     contentType: 'judge', itemId: 'next_choice');
                      controller.nextPage();
                    }
                  }
                : null,
            child: Container(
              alignment: Alignment.center,
              child: Icon(
                iconData,
                // color: AppColors.colorOnPrimary,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
