import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

void authenticationNavigator(
  BuildContext context,
  AuthState state,
) {
  print('trigger auth nav');
  // print(state.status);
  // print(context.read<AuthBloc>().state.status);
  // AuthState state = context.read<AuthBloc>().state;
  // print(state);
  String currentScreen =
      GoRouter.of(context).routeInformationProvider.value.uri.toString();
  print(currentScreen);
  // if ((state.status == AuthStatus.unauthenticated ||
  //         state.status == AuthStatus.unknown ||
  //         state.authUser == null) &&
  //     goScreen != '/welcome') {
  if ((state.status == AuthStatus.unauthenticated ||
          state.status == AuthStatus.unknown ||
          state.authUser == null) &&
      currentScreen != '/welcome') {
    print('not auth\'d, go to welcome from $currentScreen');
    context.goNamed('welcome');
  } else if (state.status == AuthStatus.authenticated &&
      state.authUser != null &&
      currentScreen != '/home') {
    print('auth\'d, to home from $currentScreen');
    context.goNamed('home');
  } else {
    print('don\'t nav just yet..');
  }
  // TODO: TOS, et al
  // Note: Splash is passing UserState down; ScreenWrapper only AuthState
}
