import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
// import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> deleteAccount(BuildContext context) async {
    var authBloc = context.read<AuthBloc>();

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
                    color: Theme.of(context).colorScheme.surface,
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
                  // TODO: actually delete the account (Auth, Firebase, & Storage)
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
        // TODO
        // await authRepository.deleteAccount();

        authBloc.add(
          SignOut(),
        );
      } catch (err) {
        print('settings delete err: $err');
        if (err is PlatformException) {
          print('is platform exception, so probably google');
          if (err.code == 'ERROR_REQUIRES_RECENT_LOGIN') {}
          // await authRepository.loginWithGoogle(
          //   email: email,
          //   password: password,
          // );

          // await authRepository.deleteAccount();

          authBloc.add(
            SignOut(),
          );
        }
      }
    }
  }

  // Future<void> signOut(BuildContext context) async {
  //   await context.read<AuthRepository>().signOut();

  //   if (context.mounted) {
  //     context.read<AuthBloc>().add(
  //           SignOut(),
  //         );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      screen: 'Settings',
      goBackTo: 'home',
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
                title: 'Theme',
                subtitle: context.read<UserBloc>().state.user.isDarkTheme
                    ? 'Dark'
                    : 'Light',
                icon: Icon(
                  context.read<UserBloc>().state.user.isDarkTheme
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () => context.read<UserBloc>().add(
                      const UpdateTheme(
                        updateFirebase: true,
                      ),
                    ),
              ),
              Preference(
                title: 'Sign Out',
                icon: Icon(
                  MdiIcons.logout,
                  color: Theme.of(context).colorScheme.primary,
                ),
                // onTap: () => signOut(context),
                onTap: () => context.read<AuthBloc>().add(
                      SignOut(),
                    ),
              ),
              Preference(
                title: 'Delete Account',
                titleColor: Theme.of(context).colorScheme.error,
                titleWeight: FontWeight.bold,
                icon: Icon(
                  MdiIcons.deleteForeverOutline,
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
                  MdiIcons.shieldSearch,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  // Analytics > settings - privacy policy
                  print('TODO: show privacy policy');
                },
              ),
              Preference(
                title: 'Terms of Service',
                icon: Icon(
                  MdiIcons.clipboard,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  // Analytics > settings - terms of service
                  print('TODO: show tos');
                },
              ),
              Preference(
                title: 'Open Source Licenses',
                icon: Icon(
                  MdiIcons.sourceBranch,
                  color: Theme.of(context).colorScheme.primary,
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
                  MdiIcons.faceAgent,
                  color: Theme.of(context).colorScheme.primary,
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
                  MdiIcons.github,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  // Analytics > settings - contribute
                  print('TODO: show github');
                },
              ),
              Preference(
                title: 'Built by the 52inc & DTFun',
                icon: Icon(
                  Icons.people,
                  color: Theme.of(context).colorScheme.primary,
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
                                    updateFirebase: true,
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
                            MdiIcons.application,
                            color: Theme.of(context).colorScheme.primary,
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
                            MdiIcons.restore,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onTap: () {
                            context.read<UserBloc>().add(
                                  UpdateUser(
                                    updateFirebase: true,
                                    user: state.user.copyWith(
                                      developerPackEnabled: false,
                                      isDarkTheme: false,
                                      playerLimit: Game.initPlayerLimit,
                                      prizesToWin: Game.initPrizesToWin,
                                    ),
                                  ),
                                );
                          },
                        ),
                        Preference(
                          title: 'Developer packs',
                          subtitle: 'Custom card packs from the developer',
                          trailing: state.user.developerPackEnabled
                              ? const Text(
                                  'ENABLED',
                                  style: TextStyle(color: Colors.green),
                                )
                              : const Text(
                                  'DISABLED',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                          icon: Icon(
                            state.user.developerPackEnabled
                                ? Icons.developer_board
                                : Icons.developer_board_off,
                            color: Theme.of(context).colorScheme.primary,
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
                  child: SizedBox(
                    child: Text(
                      'All CAH or "Cards Against Humanity" question and answer text are licensed under Creative Commons BY-NC-SA 4.0 by the owner Cards Against Humanity, LLC. This application is NOT official, produced, endorsed or supported by Cards Against Humanity, LLC.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
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
                      // https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
                    },
                    child: Image.asset(
                      'assets/images/cc_by_nc_sa.png',
                      width: 96,
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
