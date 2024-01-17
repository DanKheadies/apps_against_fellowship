import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> deleteAccount(BuildContext context) async {
    var authBloc = context.read<AuthBloc>();
    // var authRepository = context.read<AuthRepository>();

    bool result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete account?',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.redAccent,
                  ),
            ),
            content: Text(
              'Are you sure you want to delete your account? This is permenant and cannot be undone.',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text(
                  'DELETE ACCOUNT',
                  style: TextStyle(
                    color: Colors.redAccent,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });

    if (result) {
      print('result was true, so delete');
      // Analytics > setting - delete account
      try {
        // await authRepository.deleteAccount();
        authBloc.add(
          SignOut(),
        );
        // TODO: verify that ScreenWrapper navigates
      } catch (err) {
        print('settings delete err: $err');
        if (err is PlatformException) {
          print('is platform exception, so probably google');
          if (err.code == 'ERROR_REQUIRES_RECENT_LOGIN') ;
          // await authRepository.loginWithGoogle(
          //   email: email,
          //   password: password,
          // );
          // await authRepository.deleteAccount();
          authBloc.add(
            SignOut(),
          );
          // TODO: verify that ScreenWrapper navigates
        }
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    var authBloc = context.read<AuthBloc>();
    var authRepository = context.read<AuthRepository>();
    await authRepository.signOut();
    authBloc.add(
      SignOut(),
    );
    // TODO: verify that ScreenWrapper navigates
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      screen: 'Settings',
      // hideAppBar: true,
      goBack: 'home',
      child: ListView(
        children: [
          PreferenceCategory(
            title: 'Account',
            children: [
              UserPreference(
                onTap: (user) {
                  // Analytics > settings - profile
                  context.goNamed('profile');
                },
              ),
              Preference(
                title: 'Sign Out',
                icon: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onTap: () => signOut(context),
              ),
              Preference(
                title: 'Delete Account',
                titleColor: Theme.of(context).colorScheme.error,
                titleWeight: FontWeight.bold,
                icon: Icon(
                  Icons.delete_forever_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                onTap: () => deleteAccount(context),
              ),
            ],
          ),
          PreferenceCategory(
            title: 'Legal',
            children: [
              Preference(
                title: 'Privacy Policy',
                icon: Icon(
                  Icons.shield_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  // Analytics > settings - privacy policy
                  print('TODO: show privacy policy');
                },
              ),
              Preference(
                title: 'Terms of Service',
                icon: Icon(
                  Icons.format_align_left,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  // Analytics > settings - terms of service
                  print('TODO: show tos');
                },
              ),
              Preference(
                title: 'Open Source Licenses',
                icon: Icon(
                  Icons.source_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  // Analytics > settings - open source licenses
                  print('TODO: show open source licenses');
                },
              ),
            ],
          ),
          PreferenceCategory(
            title: 'About',
            children: [
              Preference(
                title: 'Feedback',
                subtitle: 'Provide feedback on issues or improvements',
                icon: Icon(
                  Icons.face,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  // Analytics > settings - feedback
                  print('TODO: open wiredash & feedback');
                },
              ),
              Preference(
                title: 'Contribute',
                subtitle: 'Checkout the source code on GitHub!',
                icon: Icon(
                  Icons.code,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  // Analytics > settings - contribute
                  print('TODO: show github');
                },
              ),
              Preference(
                title: 'Built by the Fellowship of the Apps',
                icon: Icon(
                  Icons.people,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  // Analytics > settings - author
                  print('TODO: show author');
                },
              ),
              StreamBuilder<PackageInfo>(
                stream: PackageInfo.fromPlatform().asStream(),
                builder: (context, snapshot) {
                  var packageInfo = snapshot.data;
                  return BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return FrequentTapDetector(
                        threshold: 5,
                        onTapCountReachedCallback: () {
                          if (!state.user.developerPackEnabled) {
                            // Analytics > setting - dev packs
                            context.read<UserBloc>().add(
                                  UpdateUser(
                                    user: state.user.copyWith(
                                      developerPackEnabled: true,
                                    ),
                                  ),
                                );
                            // setState(() {});
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 3),
                                  content:
                                      const Text('Developer Packs Unlocked!'),
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: 'VIEW',
                                    textColor:
                                        Theme.of(context).colorScheme.primary,
                                    onPressed: () {
                                      context.goNamed('createGame');
                                    },
                                  ),
                                ),
                              );
                          }
                        },
                        child: Preference(
                          title: 'Version',
                          icon: Icon(
                            Icons.developer_mode,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          subtitle: packageInfo != null
                              ? '${packageInfo.version}+${packageInfo.buildNumber}'
                              : 'Loading...',
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          kDebugMode
              ? BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    return PreferenceCategory(
                      title: 'Debug',
                      children: [
                        Preference(
                          title: 'Reset Preferences',
                          subtitle:
                              'Clear out the preferences to their default state',
                          icon: Icon(
                            Icons.restore,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          onTap: () {
                            context.read<UserBloc>().add(
                                  UpdateUser(
                                    user: state.user.copyWith(
                                      developerPackEnabled: false,
                                      isDarkTheme: false,
                                      playerLimit: Game.initPlayerLimit,
                                      prizesToWin: Game.initPrizesToWin,
                                    ),
                                  ),
                                );
                            // setState(() {});
                          },
                        ),
                        Preference(
                          title: "Developer packs",
                          subtitle: "Custom card packs from the developer",
                          trailing: state.user.developerPackEnabled
                              ? const Text(
                                  "ENABLED",
                                  style: TextStyle(color: Colors.green),
                                )
                              : const Text(
                                  "DISABLED",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                          // icon: Image.asset(
                          //   'assets/ic_logo.png',
                          //   color: context.secondaryColorOnCard,
                          // ),
                          icon: Icon(
                            state.user.developerPackEnabled
                                ? Icons.developer_board
                                : Icons.developer_board_off,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  },
                )
              : const SizedBox(),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    print('TODO: go to cards against humanity');
                  },
                  child: const SizedBox(
                    child: Text(
                      'All CAH or "Cards Against Humanity" question and answer text are licensed under Creative Commons BY-NC-SA 4.0 by the owner Cards Against Humanity, LLC. This application is NOT official, produced, endorsed or supported by Cards Against Humanity, LLC.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 16,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      print('TODO: go to CC');
                    },
                    // child: Image.asset(
                    //   'cc.png',
                    //   width: 96,
                    // ),
                    child: const Icon(
                      Icons.copyright,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
