import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/services/services.dart';
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

  // void authenticationNavigator(
  //   BuildContext context,
  //   AuthState state,
  // ) {
  //   print('trigger screen wrapper - auth');
  //   print(state.status);
  //   String goScreen =
  //       GoRouter.of(context).routeInformationProvider.value.uri.toString();
  //   // print(screen);
  //   if ((state.status == AuthStatus.unauthenticated ||
  //           state.status == AuthStatus.unknown ||
  //           state.authUser == null) &&
  //       goScreen != '/welcome') {
  //     print('not auth\'d, go to welcome from $goScreen (aka $screen)');
  //     context.goNamed('welcome');
  //   } else if (state.status == AuthStatus.authenticated &&
  //       state.authUser != null &&
  //       goScreen == '/welcome') {
  //     print('auth\'d, to home from $goScreen (aka $screen)');
  //     context.goNamed('home');
  //   } else {
  //     print('else');
  //   }
  //   // TODO: TOS, et al
  // }

  @override
  Widget build(BuildContext context) {
    print('build wrapper for $screen');
    // Note: there's still a "double tap" to build the AAF Welcome page even w/
    // AnimatedOpacity disabled. Would like to know why. Disable all timers?
    // This basically runs anytime the AuthState changes, but Flutter is smart
    // enough to not build the downstream widgets if they don't change, i.e.
    // even if this rebuilds, the subsequent screen--Welcome screen--doesn't.
    // I think that's resolved.
    // New issue: when I dev-refresh (or probably kill the app and re-open),
    // the state doesn't get updated, i.e. we're already auth'd... The only
    // data that might change is lastUpdated... I wonder if I can simplify
    // by listening for just that, i.e. when previous != current.
    // But I would expect this to trigger based on that.
    // Ahhhh right, ScreenWrapper is not in place to listen and navigate when
    // the auth sub/stream runs. The app fires up, the Splash screen animates,
    // the auth sub/stream has new data, and THEN we navigate to Welcome where
    // this listener kicks off... So for all the times we listen to auth changes
    // i.e. login, register, etc., they occur while on this screen. But if its
    // an auth change that occurred before getting here, i.e. sub/stream via
    // Firebase or GoogleSilent while user is on Splash, then this doesn't help,
    // i.e. this listener never triggers navigation, and we sit on thumbs up.
    // Hence, we have that postFrameCallback to check auth and nav...
    // Not sure if I like this approach because it's not completely consolidated.
    // You'd have to follow the bread-crumbs to figure out when you navigate and
    // why.
    // Alt option: handle it via Splash navigation
    // Thoughts: AuthBloc should remain as behind the scenes logic; I want Splash
    // to finish it's animation (or have the user tap) before navigation triggers;
    // I don't want to have a "handleAuthentication" function waitin on Welcome.
    // Either we know where we're going or a listener is waiting to be told.
    // What a jabroni.. I did have that as the solution.. Before.
    return BlocListener<AuthBloc, AuthState>(
      // listener: (context, state) {
      //   print('trigger screen wrapper - auth');
      //   print(state.status);
      //   String goScreen =
      //       GoRouter.of(context).routeInformationProvider.value.uri.toString();
      //   // print(screen);
      //   if ((state.status == AuthStatus.unauthenticated ||
      //           state.status == AuthStatus.unknown ||
      //           state.authUser == null) &&
      //       goScreen != '/welcome') {
      //     print('not auth\'d, go to welcome from $goScreen (aka $screen)');
      //     context.goNamed('welcome');
      //   } else if (state.status == AuthStatus.authenticated &&
      //       state.authUser != null &&
      //       goScreen == '/welcome') {
      //     print('auth\'d, to home from $goScreen (aka $screen)');
      //     context.goNamed('home');
      //   } else {
      //     print('else');
      //   }
      //   // TODO: TOS, et al
      // },
      listener: (context, state) => authenticationNavigator(context, state),
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
