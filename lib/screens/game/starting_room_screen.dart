import 'package:flutter/material.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';

class StartingRoomScreen extends StatelessWidget {
  final GameState state;

  const StartingRoomScreen({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // brightness: Brightness.dark,
        // textTheme: context.theme.textTheme,
        // iconTheme: context.theme.iconTheme,
        title: const Text("Game is starting..."),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Container(
            height: 72,
            padding: const EdgeInsets.only(bottom: 8),
            alignment: Alignment.center,
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 72),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Game ID",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.background,
                            ),
                      ),
                      Text(
                        state.game.gameId,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // body: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     Row(
      //       msinAxisSize: MainAxisSize.max,
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       children: [
      //         Container(
      //           child: CircularProgressIndicator(),
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
