import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

void authenticationNavigator(
  BuildContext context,
  AuthState stateHolder,
) {
  // print('trigger auth nav');
  // print(
  //   'have authUser: ${stateHolder.authUser != null ? 'true' : 'false'}',
  // );
  String currentScreen =
      GoRouter.of(context).routeInformationProvider.value.uri.toString();
  // print(currentScreen);
  AuthState state = context.read<AuthBloc>().state;

  // Keep unauthenticated users at Welcome (note: Splash has no authNav)
  if ((state.status == AuthStatus.unauthenticated ||
          state.status == AuthStatus.unknown ||
          state.authUser == null) &&
      currentScreen != '/welcome') {
    // print('not auth\'d, go to welcome from $currentScreen');
    context.goNamed('welcome');
  }
  // Avoid landing on Welcome if user is authenticated (exception: Splash)
  else if (state.status == AuthStatus.authenticated &&
      state.authUser != null &&
      (currentScreen == '/' || currentScreen == '/welcome')) {
    // print('auth\'d, to home from $currentScreen');
    context.goNamed('home');
    // } else {
    // print('don\'t nav just yet..');
  }
}
