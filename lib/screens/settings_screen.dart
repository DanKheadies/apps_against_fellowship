import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/cubits/cubits.dart';
import 'package:apps_against_fellowship/helpers/helpers.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late WebViewController webViewCont;

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
                subtitle: context.read<DeviceCubit>().state.isDarkTheme
                    ? 'Dark'
                    : 'Light',
                icon: Icon(
                  context.read<DeviceCubit>().state.isDarkTheme
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () => context.read<DeviceCubit>().toggleTheme(),
              ),
              Preference(
                title: 'Sign Out',
                icon: Icon(
                  MdiIcons.logout,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () => fullSignOut(context),
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
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return PreferenceCategory(
                title: 'Audio',
                children: [
                  const SizedBox(height: 10),
                  SettingsToggle(
                    'All Audio',
                    Icon(
                      state.hasAudioOn ? Icons.volume_up : Icons.volume_off,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onSelected: () => context.read<SettingsBloc>().add(
                          ToggleAudio(),
                        ),
                  ),
                  const SizedBox(height: 25),
                  SettingsToggle(
                    'Sound FX',
                    Icon(
                      state.hasSoundsOn ? Icons.graphic_eq : Icons.volume_off,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onSelected: () => context.read<SettingsBloc>().add(
                          ToggleSound(),
                        ),
                  ),
                  const SizedBox(height: 25),
                  SettingsToggle(
                    'Music',
                    Icon(
                      state.hasMusicOn ? Icons.music_note : Icons.music_off,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onSelected: () => context.read<SettingsBloc>().add(
                          ToggleMusic(),
                        ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Slider(
                      value: state.musicVolume,
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor: Theme.of(context).colorScheme.surface,
                      onChanged: (value) => context.read<SettingsBloc>().add(
                            SetMusicVolume(level: value),
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left),
                          onPressed: () =>
                              context.read<AudioCubit>().prevSong(),
                        ),
                        BlocBuilder<AudioCubit, AudioState>(
                          builder: (context, state) {
                            return Text(
                              state.currentSongTitle,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right),
                          onPressed: () =>
                              context.read<AudioCubit>().nextSong(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              );
            },
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
                onTap: () async {
                  // Analytics > settings - privacy policy
                  final Uri url = Uri.parse(
                    'https://apps-against-fellowship.web.app/privacy.html',
                  );
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
              ),
              Preference(
                title: 'Terms of Service',
                icon: Icon(
                  MdiIcons.clipboard,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () async {
                  // Analytics > settings - terms of service
                  final Uri url = Uri.parse(
                    'https://apps-against-fellowship.web.app/tos.html',
                  );
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
              ),
              Preference(
                title: 'Open Source Licenses',
                icon: Icon(
                  MdiIcons.sourceBranch,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () async {
                  // Analytics > settings - open source licenses
                  //
                  final Uri url = Uri.parse(
                    'https://opensource.org/license/gpl-3-0',
                  );
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
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
                  HelpDialog.openHelpDialog(context);
                },
              ),
              Preference(
                title: 'Contribute',
                subtitle: 'Checkout the source code on GitHub!',
                icon: Icon(
                  MdiIcons.github,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () async {
                  // Analytics > settings - contribute
                  final Uri url = Uri.parse(
                    'https://github.com/DanKheadies/apps_against_fellowship',
                  );
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
              ),
              Preference(
                title: 'Built by the 52inc & DTFun',
                icon: Icon(
                  Icons.people,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {},
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
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 3),
                                  content: const Text(
                                    'Developer Packs Unlocked!',
                                  ),
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
                  onTap: () async {
                    print('TODO: go to cards against humanity');
                    final Uri url = Uri.parse(
                      'https://www.cardsagainsthumanity.com/',
                    );
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
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
                    onTap: () async {
                      print('TODO: go to CC');
                      final Uri url = Uri.parse(
                        'https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode',
                      );
                      if (!await launchUrl(url)) {
                        throw Exception('Could not launch $url');
                      }
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

  Future<void> deleteAccount(BuildContext context) async {
    bool result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete account?',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.error,
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
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(
                  'DELETE ACCOUNT',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
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
      // Analytics > setting - delete account
      if (context.mounted) {
        fullSignOut(context, isDeletion: true);
      } else {
        print('delete account error; context not mounted');
      }
    }
  }
}
