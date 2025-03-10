import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

void authenticationNavigator(
  BuildContext context,
  AuthState stateHolder,
) {
  print('trigger auth nav');
  print(
    'have authUser: ${stateHolder.authUser != null ? 'true' : 'false'}',
  );
  String currentScreen =
      GoRouter.of(context).routeInformationProvider.value.uri.toString();
  // print(currentScreen);
  AuthState state = context.read<AuthBloc>().state;

  if ((state.status == AuthStatus.unauthenticated ||
          state.status == AuthStatus.unknown ||
          state.authUser == null) &&
      currentScreen != '/welcome') {
    print('not auth\'d, go to welcome from $currentScreen');
    context.goNamed('welcome');
  } else if (state.status == AuthStatus.authenticated &&
          state.authUser != null
          // && currentScreen != '/home'
          &&
          (currentScreen == '/' || currentScreen == '/welcome')
      // Note: helps avoid spamming on home, but will cause a nav back to home
      // on other screens, e.g. uploading a new profile photo.
      ) {
    print('auth\'d, to home from $currentScreen');
    context.goNamed('home');
  } else {
    print('don\'t nav just yet..');
  }
  // TODO: TOS, et al
  // Note: Splash is passing UserState down; ScreenWrapper only AuthState
  // Can use context.read to get accurate info here
}
