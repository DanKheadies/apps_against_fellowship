import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ScreenWrapper extends StatelessWidget {
  final AppBar? customAppBar;
  final bool? canScroll;
  final bool? hideAppBar;
  final BottomAppBar? customBottAppBar;
  final FloatingActionButton? flaction;
  final FloatingActionButtonLocation? flactionLocation;
  final List<Widget>? actions;
  final String? goBackTo;
  final String screen;
  final VoidCallback? specialBack;
  final Widget child;

  const ScreenWrapper({
    super.key,
    required this.child,
    required this.screen,
    this.actions,
    this.canScroll = true,
    this.customAppBar,
    this.customBottAppBar,
    this.flaction,
    this.flactionLocation,
    this.goBackTo = '',
    this.hideAppBar = false,
    this.specialBack,
  });

  @override
  Widget build(BuildContext context) {
    // print('build wrapper');

    // Update: this logic is kinda problematic, i.e. we navigate as soon as we
    // get the Auth g2g but we're still getting user data. So when we go to Home
    // and start loading up that bloc, we don't have the userId to accurately sub
    // / stream to.
    // Fix(?)
    // 1. Add a timer here--should solve 95-99% of use cases--to delay nav.
    // 2. Listen to Auth and User, which will cause this to re-build a good bit.
    // 3. Keep as is, but focus on the AuthBloc and don't trigger authenticated
    // until we have user info there.
    // return Title(
    //   title: 'test',
    //   color: Colors.blue,
    //   child: Scaffold(
    //     body: Center(
    //       child: Text(
    //         'Hello World 2',
    //         style: TextStyle(
    //           color: Colors.black,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('trigger screen wrapper - auth');
        String screen =
            GoRouter.of(context).routeInformationProvider.value.uri.toString();
        print(screen);
        if (state.status == AuthStatus.unauthenticated ||
            state.status == AuthStatus.unknown) {
          print('not auth\'d, stay at welcome');
          context.goNamed('welcome');
        } else if (state.status == AuthStatus.authenticated &&
            screen == '/welcome') {
          print('auth\'d, to home');
          context.goNamed('home');
        }
        // TODO: TOS, et al
      },
      // TOOD: see ii-CC about hasSubscription for notifications
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
                              Icons.arrow_back,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed:
                                specialBack ?? () => context.goNamed(goBackTo!),
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
            child: child,
          ),
        ),
      ),
    );
  }
}
