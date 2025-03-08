import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/cubits/cubits.dart';
import 'package:apps_against_fellowship/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Controls
class ScreenWrapper extends StatelessWidget {
  final AppBar? customAppBar;
  final bool? avoidLongPressThemeChange;
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
    this.avoidLongPressThemeChange = false,
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
    print('build wrapper for $screen');
    // TODO: upgrade to multibloc listener and combine into AppsAF (?).
    // Let this be "purely" a way to deliver consistent UI / widget look n feel.
    // Let AppsAF handle all logic actions, e.g. authentication, app state, etc.
    // Update: nope we need info on GoRouter context to make the nav work.
    // We supply it at the time of MaterialApp.router instantiation, not before.
    // In other words, can't work on AppsAF b/c there's no info when we call it.
    // Can keep here...
    return BlocListener<AuthBloc, AuthState>(
      // TODO: listenWhen status changes or authUser (?)
      // Updating a profile pic triggers this atm; not the goal.
      listener: (context, state) => authenticationNavigator(context, state),
      // listener: (context, state) => print('derp'),
      // Note: passing this state is stale in AuthHav, but context.read<>
      // is up-to-date. Keeping for listener, but odd...
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
          body: avoidLongPressThemeChange!
              ? child
              : InkWell(
                  onLongPress: () {
                    // context.read<UserBloc>().add(
                    //       const UpdateTheme(
                    //         updateFirebase: false,
                    //       ),
                    //     );
                    context.read<DeviceCubit>().toggleTheme();
                  },
                  child: child,
                ),
        ),
      ),
    );
  }
}
