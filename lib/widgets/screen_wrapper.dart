import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/cubits/cubits.dart';
import 'package:apps_against_fellowship/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Controls the overall UX / UI for consistency across screens as well as
/// handling authentication access and navigation.
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
    // print('build wrapper for $screen');
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => authenticationNavigator(context, state),
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
                    context.read<DeviceCubit>().toggleTheme();
                  },
                  child: child,
                ),
        ),
      ),
    );
  }
}
