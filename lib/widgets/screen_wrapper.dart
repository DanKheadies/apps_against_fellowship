import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ScreenWrapper extends StatelessWidget {
  final AppBar? customAppBar;
  final bool? avoidThemeChange;
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
    this.avoidThemeChange = false,
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
    return BlocListener<AuthBloc, AuthState>(
      // TODO: listenWhen status changes or authUser (?)
      // Updating a profile pic triggers this atm; not the goal.
      listener: (context, state) => authenticationNavigator(context, state),
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
          body: avoidThemeChange!
              ? child
              : InkWell(
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
