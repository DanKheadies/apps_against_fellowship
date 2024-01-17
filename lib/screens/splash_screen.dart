import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool played = false;
  int fileIndex = 0;
  List<String> files = [
    'cards-green',
    'cards-people',
  ];

  late AnimationController aniCont;
  late Timer navTimer;

  @override
  void initState() {
    super.initState();

    aniCont = AnimationController(
      vsync: this,
    );

    navTimer = Timer(
      Duration.zero,
      () {},
    );

    fileIndex = Random().nextInt(files.length);
  }

  void decideRoute(
    BuildContext context,
    AuthState authState,
    UserState userState,
  ) {
    if (authState.status == AuthStatus.unauthenticated ||
        authState.status == AuthStatus.unknown) {
      print('to sign in');
      context.goNamed('signIn');
    } else if (authState.status == AuthStatus.authenticated &&
        !userState.user.acceptedTerms) {
      print('to tos');
      context.goNamed('tos');
    } else if (authState.status == AuthStatus.authenticated) {
      print('to home');
      context.goNamed('home');
    } else {
      print('No route could be decided.');
    }
  }

  @override
  void dispose() {
    aniCont.dispose();
    navTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Apps Against Fellowship',
      color: Colors.purple, // TODO: does what?
      child: Scaffold(
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                return InkWell(
                  onTap: () => decideRoute(context, authState, userState),
                  child: Center(
                    child: Center(
                      child: Lottie.asset(
                        'assets/images/splash/${files[fileIndex]}.json',
                        controller: aniCont,
                        onLoaded: (composition) {
                          aniCont
                            ..duration = fileIndex == 0
                                ? composition.duration * 2
                                : composition.duration
                            ..forward();
                          navTimer = Timer(
                            fileIndex == 0
                                ? composition.duration * 2
                                : composition.duration,
                            () => decideRoute(context, authState, userState),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
