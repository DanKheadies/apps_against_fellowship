import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class JoinGameWidget extends StatelessWidget {
  final HomeState state;

  const JoinGameWidget({
    super.key,
    required this.state,
  });

  void joinGame(BuildContext context) async {
    var homeCont = context.read<HomeBloc>();
    var gameId = await showJoinRoomDialog(context);
    if (gameId != null) {
      homeCont.add(
        JoinGame(
          gameCode: gameId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeOutlineButton(
      icon: state.joiningGame == ''
          ? Icon(
              MdiIcons.gamepadVariantOutline,
              color: Theme.of(context).colorScheme.primary,
            )
          : const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            ),
      text: state.joiningGame == '' ? 'Join Game' : 'Joining Game...',
      onTap: () {
        // Analytics > 'join game'
        // Push Notification > check permissions
        joinGame(context);
      },
    );
  }
}
