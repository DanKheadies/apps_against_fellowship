import 'dart:async';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/cubits/cubits.dart';
// import 'package:apps_against_fellowship/cubits/cubits.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in_web/web_only.dart' as web;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
      context.read<AuthBloc>().add(
            LoginWithGoogle(isSilent: true),
          );
    }
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
    // print('build welcome screen');
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleError,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.submitting) {
            return ScreenWrapper(
              screen: 'Apps AF',
              hideAppBar: true,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state.status == AuthStatus.authenticated) {
            return ScreenWrapper(
              screen: 'Apps AF',
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

            return ScreenWrapper(
              screen: method == AuthMethod.login
                  ? 'Login'
                  : method == AuthMethod.register
                      ? 'Register'
                      : 'Apps AF',
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
      ),
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
          // context.read<UserBloc>().state.user.isDarkTheme
          context.read<DeviceCubit>().state.isDarkTheme
              ? Icons.dark_mode
              : Icons.light_mode,
        ),
        onPressed: () {
          // context.read<UserBloc>().add(
          //       UpdateTheme(updateFirebase: false),
          //     );
          context.read<DeviceCubit>().toggleTheme();
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
                            MdiIcons.apple,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          text: 'Apple',
                          onTap: buttOpacTimer.isActive
                              ? null
                              : () => context.read<AuthBloc>().add(
                                    LoginWithApple(isWeb: kIsWeb),
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height / 2 + 25,
                  left: 0,
                  child: AnimatedOpacity(
                    opacity: buttonOpacity,
                    duration: const Duration(seconds: 1),
                    child: SizedBox(
                      width: size.width,
                      child: Center(
                        child:
                            // TODO: finish Google sign-in for web
                            // Still having issues w/ authorization; TBContinued
                            kIsWeb
                                ? web.renderButton()
                                : HomeOutlineButton(
                                    icon: Icon(
                                      MdiIcons.google,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    text: 'Google',
                                    onTap: buttOpacTimer.isActive
                                        ? null
                                        : () => context.read<AuthBloc>().add(
                                              LoginWithGoogle(isWeb: kIsWeb),
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

  void _handleError(
    BuildContext context,
    AuthState state,
  ) {
    if (state.errorMessage != '' && state.errorMessage != null) {
      // String errorMsg = state.errorMessage!
      //     .replaceAll('Exception: ', '')
      //     .replaceAll(RegExp('\\[.*?\\]'), '');

      String errMsg = state.errorMessage!.contains(']')
          ? state.errorMessage!
              .split(']')[1]
              .split('\n')[0]
              .replaceFirst(' ', '')
          : state.errorMessage!;

      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errMsg),
            duration: const Duration(milliseconds: 4200),
          ),
        ).closed.then(
              (value) => context.mounted
                  ? context.read<AuthBloc>().add(
                        ResetError(),
                      )
                  : null,
            );
    }
  }
}
