import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
// import 'package:apps_against_fellowship/config/config.dart';

class ScreenWrapper extends StatefulWidget {
  final String screen;
  final Widget child;

  const ScreenWrapper({
    super.key,
    required this.child,
    required this.screen,
  });

  @override
  State<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends State<ScreenWrapper> {
  @override
  void initState() {
    super.initState();
    print('init screen wrapper');
    var derp = context.read<UserBloc>().state;
    print('derp: $derp');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('auth bloc listener');
        if (state.status == AuthStatus.authenticated) {
          print('auth\'d so home');
          context.goNamed('home');
        } else if (state.status == AuthStatus.unauthenticated ||
            state.status == AuthStatus.unknown) {
          print('not auth\'d: ${state.status}');
          context.goNamed('signIn');
        } else {
          print('auth is submitting..');
        }
      },
      child: Title(
        title: widget.screen,
        color: Colors.red,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.screen),
          ),
          body: widget.child,
        ),
      ),
    );
  }
}
