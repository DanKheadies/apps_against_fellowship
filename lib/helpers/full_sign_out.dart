import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> fullSignOut(
  BuildContext context, {
  bool? isDeletion,
}) async {
  context.read<GameBloc>().add(
        CloseGameStreams(),
      );
  context.read<HomeBloc>().add(
        CloseHomeStreams(),
      );

  if (isDeletion != null) {
    context.read<AuthBloc>().add(
          DeleteAccount(),
        );
  } else {
    context.read<AuthBloc>().add(
          SignOut(),
        );
  }
}
