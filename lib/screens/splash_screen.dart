import 'dart:async';
import 'dart:math';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
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
          builder: (context, state) {
            return InkWell(
              onTap: () => authenticationNavigator(context, state),
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
                      () => authenticationNavigator(context, state),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
