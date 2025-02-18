import 'dart:async';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import 'package:google_sign_in_web/web_only.dart' as web;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum AuthMethod {
  login,
  register,
  tbd,
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  AuthMethod method = AuthMethod.tbd;
  bool hideAppBar = true;
  double buttonOpacity = 0;
  double titleOpacity = 0.420;

  late Timer authenticationTimer;
  late Timer buttOpacTimer = Timer(
    const Duration(milliseconds: 300),
    () => setState(() {
      buttonOpacity = 1.0;
    }),
  );
  late Timer titleOpacTimer = Timer(
    const Duration(milliseconds: 100),
    () => setState(() {
      titleOpacity = 1.0;
    }),
  );

  @override
  void initState() {
    super.initState();

    authenticationTimer = Timer(Duration.zero, () {});
    buttOpacTimer;
    titleOpacTimer;

    if (!kIsWeb) {
      // context.read<AuthBloc>().add(
      //       // LoginWithGoogleSilently(),
      //       SignOut(),
      //     );
    }
    // Note: Google user is throwing a null issue / red screen
    // Some values are set as null on creation for Google but not Register
    // or anon?
    // UPDATE: Google silent sign in is causing us to be validated, but homeBloc
    // runs (and the subscription) without having a user Id to get data.
    // Order of operations seems to have gone "bump," happens w/ anon too.
  }

  @override
  void dispose() {
    authenticationTimer.cancel();
    buttOpacTimer.cancel();
    titleOpacTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build welcome screen');
    // return ScreenWrapper(
    //   screen: 'Derp',
    //   child: Center(
    //     child: Text('Hello World',
    //         style: TextStyle(
    //           color: Colors.black,
    //         )),
    //   ),
    // );
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print('auth bloc builder on welcome screen');
        if (state.status == AuthStatus.submitting) {
          return ScreenWrapper(
            screen: 'welcome',
            hideAppBar: true,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state.status == AuthStatus.authenticated) {
          _checkAuthentication(state);
          // print('auth state:');
          // print(state);
          // Update: hmmm.. At this point, AuthUserChanged has triggered, which
          // means we updated the UserBloc, and ScreenWrapper has a new state.
          // Going to convert the timer to a function and see what happens.
          // Might just want to use the "execute when everything is built" trigger?

          return ScreenWrapper(
            screen: 'welcome',
            hideAppBar: true,
            child: Center(
              child: GestureDetector(
                onLongPress: () {
                  context.read<AuthBloc>().add(
                        SignOut(),
                      );
                },
                child: Icon(
                  Icons.thumb_up_alt_outlined,
                  color: Theme.of(context).colorScheme.surface,
                  size: 50,
                ),
              ),
            ),
          );
        } else {
          Size size = MediaQuery.of(context).size;

          // TODO: this spams if email in use (i.e. doesn't get cleared)
          // TODO: check / test this
          if (state.errorMessage != '' && state.errorMessage != null) {
            _handleError(state, context);
          }

          return ScreenWrapper(
            screen: method == AuthMethod.login
                ? 'Login'
                : method == AuthMethod.register
                    ? 'Register'
                    : 'AAF Welcome',
            hideAppBar: method == AuthMethod.tbd,
            goBackTo: 'welcome',
            specialBack: () => setState(() {
              method = AuthMethod.tbd;
            }),
            actions: _buildWelcomeActions(),
            flaction: _buildWelcomeFlaction(),
            child: method == AuthMethod.tbd
                ? _buildWelcomeLanding(size)
                : _buildWelcomeAuthentication(size),
          );
        }
      },
    );
  }

  FloatingActionButton? _buildWelcomeFlaction() {
    return method != AuthMethod.tbd
        ? FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              setState(() {
                method = AuthMethod.tbd;
              });
            },
            backgroundColor:
                Theme.of(context).floatingActionButtonTheme.backgroundColor,
            child: Icon(
              Icons.arrow_back,
              color:
                  Theme.of(context).floatingActionButtonTheme.foregroundColor,
            ),
          )
        : null;
  }

  List<Widget> _buildWelcomeActions() {
    return [
      IconButton(
        icon: Icon(Icons.chat_bubble),
        onPressed: () => HelpDialog.openHelpDialog(context),
      ),
      IconButton(
        icon: Icon(
          context.read<UserBloc>().state.user.isDarkTheme
              ? Icons.dark_mode
              : Icons.light_mode,
        ),
        onPressed: () {
          context.read<UserBloc>().add(
                UpdateTheme(updateFirebase: true),
              );
        },
      ),
    ];
  }

  SizedBox _buildWelcomeAuthentication(Size size) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Authentication(
          isRegister: method == AuthMethod.register ? true : false,
        ),
      ),
    );
  }

  SizedBox _buildWelcomeLanding(Size size) {
    return SizedBox(
      height: size.height,
      width: size.width,
      child: GestureDetector(
        onTap: () {
          buttOpacTimer.cancel();
          titleOpacTimer.cancel();

          setState(() {
            buttonOpacity = 1;
            titleOpacity = 1;
          });
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned(
                  top: 80,
                  left: 0,
                  child: AnimatedOpacity(
                    opacity: titleOpacity,
                    duration: const Duration(seconds: 1),
                    child: Container(
                      width: size.width,
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                      ),
                      child: Text(
                        // TODO: convert for internationalization
                        'Apps Against Fellowship',
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height / 2 - 50,
                  left: 0,
                  child: AnimatedOpacity(
                    opacity: buttonOpacity,
                    duration: const Duration(seconds: 1),
                    child: SizedBox(
                      width: size.width,
                      child: Center(
                        child: HomeOutlineButton(
                          icon: Icon(
                            MdiIcons.logout,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          text: 'Sign Out',
                          onTap: buttOpacTimer.isActive
                              ? null
                              // : () => context.goNamed('google'),
                              : () => context.read<AuthBloc>().add(
                                    SignOut(),
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),
                // TODO: add Apple auth (and then Apple auth for web)
                kIsWeb
                    ? const SizedBox()
                    : Positioned(
                        top: size.height / 2 + 25,
                        left: 0,
                        child: AnimatedOpacity(
                          opacity: buttonOpacity,
                          duration: const Duration(seconds: 1),
                          child: SizedBox(
                            width: size.width,
                            child: Center(
                              child:
                                  // TODO: add Google sign-in for web
                                  // kIsWeb ? web.renderButton() :
                                  HomeOutlineButton(
                                icon: Icon(
                                  MdiIcons.google,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                text: 'Google',
                                onTap: buttOpacTimer.isActive
                                    ? null
                                    // : () => context.goNamed('google'),
                                    : () => context.read<AuthBloc>().add(
                                          LoginWithGoogle(),
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ),
                Positioned(
                  top: size.height / 2 + 100,
                  left: 0,
                  child: AnimatedOpacity(
                    opacity: buttonOpacity,
                    duration: const Duration(seconds: 1),
                    child: SizedBox(
                      width: size.width,
                      child: Center(
                        child: HomeOutlineButton(
                          icon: Icon(
                            MdiIcons.login,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          text: 'Login',
                          onTap: buttOpacTimer.isActive
                              ? null
                              : () {
                                  setState(() {
                                    method = AuthMethod.login;
                                  });
                                },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height / 2 + 175,
                  left: 0,
                  child: AnimatedOpacity(
                    opacity: buttonOpacity,
                    duration: const Duration(seconds: 1),
                    child: SizedBox(
                      width: size.width,
                      child: Center(
                        child: HomeOutlineButton(
                          icon: Icon(
                            MdiIcons.creation,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          text: 'Register',
                          onTap: buttOpacTimer.isActive
                              ? null
                              : () {
                                  setState(() {
                                    method = AuthMethod.register;
                                  });
                                },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height / 2 + 250,
                  left: 0,
                  child: AnimatedOpacity(
                    opacity: buttonOpacity,
                    duration: const Duration(seconds: 1),
                    child: SizedBox(
                      width: size.width,
                      child: Center(
                        child: TextButton(
                          onPressed: buttOpacTimer.isActive
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                        RegisterAnonymously(),
                                      );
                                },
                          child: Text(
                            'Maybe Later, Play Now',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleError(
    AuthState state,
    BuildContext context,
  ) async {
    String errorMsg = state.errorMessage!
        .replaceAll('Exception: ', '')
        .replaceAll(RegExp('\\[.*?\\]'), '');

    await Future.delayed(const Duration(milliseconds: 300));

    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: const Duration(milliseconds: 4200),
          ),
        );

      context.read<AuthBloc>().add(
            ResetError(),
          );
    }
  }

  void _checkAuthentication(AuthState state) {
    // if (!authenticationTimer.isActive) {
    //   // print('not active so setting');
    //   authenticationTimer = Timer(
    //     const Duration(seconds: 3),
    //     () {
    //       print('its been 3 seconds and still here, sign out');
    //       // Update: so at this point, we've validated the user, i.e. authSub,
    //       // and we've gotten user data, i.e. userSub. If everything checks out,
    //       // we should go ahead and send them in. If it don't, then we can sign
    //       // out. Still not a big fan that the timer is the solution.
    //       print(context.read<AuthBloc>().state);
    //       context.read<AuthBloc>().add(
    //             SignOut(),
    //           );
    //     },
    //   );
    // }
    if (state.authUser != null) {
      // print('auth should be g2g, lets nav');
      // context.goNamed('home');
      SchedulerBinding.instance
          .addPostFrameCallback((_) => context.goNamed('home'));
    } else {
      // print('auth is not ready; chill but maybe include timer to sign out');
      if (!authenticationTimer.isActive) {
        // print('not active so setting');
        authenticationTimer = Timer(
          const Duration(seconds: 3),
          () {
            // print('its been 3 seconds and still here, sign out');
            // Update: so at this point, we've validated the user, i.e. authSub,
            // and we've gotten user data, i.e. userSub. If everything checks out,
            // we should go ahead and send them in. If it don't, then we can sign
            // out. Still not a big fan that the timer is the solution.
            // print(context.read<AuthBloc>().state);
            context.read<AuthBloc>().add(
                  SignOut(),
                );
          },
        );
      }
    }
  }
}
