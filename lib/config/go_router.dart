// import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// import 'package:apps_against_fellowship/blocs/blocs.dart';
// import 'package:apps_against_fellowship/cubits/cubits.dart';
// import 'package:apps_against_fellowship/models/models.dart';
// import 'package:apps_against_fellowship/repositories/database/database_repository.dart';
import 'package:apps_against_fellowship/screens/screens.dart';

final GoRouter goRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
      redirect: (context, state) => newRedirect(
        context,
        state,
        // false,
      ),
    ),
    GoRoute(
      path: '/signIn',
      name: 'signIn',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SignInScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
      redirect: (context, state) => newRedirect(
        context,
        state,
        // false,
      ),
    ),
    GoRoute(
      path: '/tos',
      name: 'tos',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const TermsOfServiceScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
      redirect: (context, state) => newRedirect(
        context,
        state,
        // true,
      ),
    ),
  ],
  errorPageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    name: 'error',
    child: const ErrorScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
      opacity: animation,
      child: child,
    ),
  ),
);

String newRedirect(
  BuildContext context,
  GoRouterState state,
  // bool needsAdmin,
) {
  print('is currently going to: ${state.uri}');

  return state.uri.toString();
}
