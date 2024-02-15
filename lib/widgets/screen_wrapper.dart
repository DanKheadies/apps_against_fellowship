import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';

class ScreenWrapper extends StatelessWidget {
  final AppBar? customAppBar;
  final bool? hideAppBar;
  final BottomAppBar? customBottAppBar;
  final FloatingActionButton? flaction;
  final FloatingActionButtonLocation? flactionLocation;
  final List<Widget>? actions;
  final String? goBackTo;
  final String screen;
  final Widget child;

  const ScreenWrapper({
    super.key,
    required this.child,
    required this.screen,
    this.actions,
    this.customAppBar,
    this.customBottAppBar,
    this.flaction,
    this.flactionLocation,
    this.goBackTo = '',
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
        color: Colors.purpleAccent,
        child: Scaffold(
          appBar: hideAppBar!
              ? null
              : customAppBar ??
                  AppBar(
                    title: Text(
                      screen,
                      style: const TextStyle().copyWith(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    actions: actions,
                    leading: goBackTo! != ''
                        ? IconButton(
                            icon: Icon(
                              Icons.chevron_left,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              context.goNamed(goBackTo!);
                            },
                          )
                        : const SizedBox(),
                  ),
          bottomNavigationBar: customBottAppBar,
          floatingActionButtonLocation: flactionLocation,
          floatingActionButton: flaction,
          body: InkWell(
            onLongPress: () {
              context.read<UserBloc>().add(
                    const UpdateTheme(
                      updateFirebase: false,
                    ),
                  );
            },
            child: child, // TODO: clean up
          ),
        ),
      ),
    );
  }
}
