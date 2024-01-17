import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';

class ScreenWrapper extends StatelessWidget {
  final bool? hideAppBar;
  final List<Widget>? actions;
  final String? goBack;
  final String screen;
  final Widget child;

  const ScreenWrapper({
    super.key,
    required this.child,
    required this.screen,
    this.actions,
    this.goBack = '',
    this.hideAppBar = false,
  });

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
        title: screen,
        color: Colors.red,
        child: Scaffold(
          appBar: hideAppBar!
              ? null
              : AppBar(
                  title: Text(screen),
                  actions: actions,
                  leading: goBack! != ''
                      ? IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                          ),
                          onPressed: () {
                            context.goNamed(goBack!);
                          },
                        )
                      : const SizedBox(),
                ),
          body: child,
        ),
      ),
    );
  }
}
