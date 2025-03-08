import 'dart:async';

import 'package:apps_against_fellowship/cubits/cubits.dart';
// import 'package:apps_against_fellowship/models/models.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
// import 'package:logging/logging.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// A bloc that holds settings like [DUCFlavor] or [hasMusicOn],
/// and saves them in a local store, i.e. hydrated.
class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  final AudioCubit _audioCubit;
  final ValueNotifier<AppLifecycleState> _appLifecycleNotifier;

  /// Creates a new instance of [SettingsState] backed by [hydration].
  /// Initializes all audio while tracking the state of the app.
  ///
  /// By default, settings are persisted using [HydratedBloc]
  /// (i.e. see hive [https://pub.dev/packages/hive] for more).
  SettingsBloc({
    required AudioCubit audioCubit,
    required ValueNotifier<AppLifecycleState> appLifecycleNotifier,
  })  : _appLifecycleNotifier = appLifecycleNotifier,
        _audioCubit = audioCubit,
        super(const SettingsState()) {
    on<CheckForUser>(_onCheckForUser);
    on<InitializeAudio>(_onInitializeAudio);
    on<InitializeAudioForWeb>(_onInitializeAudioForWeb);
    on<SetMusicVolume>(_onSetMusicVolume);
    on<ToggleAudio>(_onToggleAudio);
    on<ToggleMusic>(_onToggleMusic);
    on<TogglePause>(_onTogglePause);
    on<ToggleSound>(_onToggleSound);

    _appLifecycleNotifier.addListener(handleAppLifecycle);

    add(
      InitializeAudio(),
    );

    // TODO: turn everything off on instantiation
    // Once the user logs in, we turn everything on. If they turn them off in
    // settings, we cache that, and on subsequent loads, we hydrate from those
    // settings.
  }

  /// Makes sure the settings bloc is listening to changes of both the app
  /// lifecycle (e.g. suspend app) and to settings changes (e.g. mute sound).
  // Note: seems to always go (leaving app) inactive > hidden > paused;
  // then (returning to app) hidden > inactive > resumed
  void handleAppLifecycle() {
    switch (_appLifecycleNotifier.value) {
      case AppLifecycleState.paused:
      // print('app paused');
      case AppLifecycleState.detached:
      // print('app detached');
      case AppLifecycleState.hidden:
        // print('app hidden');
        _audioCubit.stopAllSound();
      case AppLifecycleState.resumed:
        // print('app resumed');
        if (state.hasUser && state.hasAudioOn && state.hasMusicOn) {
          _audioCubit.startOrResumeMusic();
        }
      case AppLifecycleState.inactive:
        // print('app inactive');
        break;
    }
  }

  void _onCheckForUser(
    CheckForUser event,
    Emitter<SettingsState> emit,
  ) {
    print('we have a user');
    emit(
      state.copyWith(
        hasUser: event.haveUser,
      ),
    );

    print('event.haveUser: ${event.haveUser}');
    print('state.hasAudioOn: ${state.hasAudioOn}');
    print('state.hasMusicOn: ${state.hasMusicOn}');
    if (event.haveUser && state.hasAudioOn && state.hasMusicOn) {
      _audioCubit.startOrResumeMusic();
    }
    if (!event.haveUser) {
      // _audioCubit.releaseMusicPlayer(state.previousMusicPlayerId);
      _audioCubit.stopAllSound();
    }
  }

  void _onInitializeAudio(
    InitializeAudio event,
    Emitter<SettingsState> emit,
  ) {
    // Update: the goal here should be to initialize audioCubit's music player
    // stream. We also load the SFX in that step, which could be avoided / waited
    // for until there's a user. But in this case, it's a small load w/ minimal
    // impact.
    // print('settings bloc');
    // if (state.hasAudioOn && state.hasMusicOn) {
    //   // On the web, sound can only start after user interaction, so
    //   // we start muted there on every game start.
    //   if (kIsWeb) {
    //     // Logger('SettingsBloc').info(
    //     //   'On the web, music can only start after user interaction.',
    //     // );
    //     print('On the web, music can only start after user interaction.');
    //     add(
    //       InitializeAudioForWeb(),
    //     );
    //   } else {
    //     // _audioCubit.playCurrentSongInPlaylist();
    //     _audioCubit.initializeAudio();
    //   }
    // }
    // print('set music vol: ${state.musicVolume}');
    // _audioCubit.setMusicVolume(state.musicVolume);
    print('settings bloc - init audio');
    String currentMusicPlayerId =
        _audioCubit.initializeAudio(state.previousMusicPlayerId);
    print('set music vol: ${state.musicVolume}');
    _audioCubit.setMusicVolume(state.musicVolume);

    print('new previousMusicPlayerId: $currentMusicPlayerId');
    emit(
      state.copyWith(
        previousMusicPlayerId: currentMusicPlayerId,
      ),
    );
  }

  void _onInitializeAudioForWeb(
    InitializeAudioForWeb event,
    Emitter<SettingsState> emit,
  ) {
    emit(
      state.copyWith(
        hasAudioOn: false,
      ),
    );
  }

  void _onSetMusicVolume(
    SetMusicVolume event,
    Emitter<SettingsState> emit,
  ) {
    _audioCubit.setMusicVolume(event.level);
    emit(
      state.copyWith(
        musicVolume: event.level,
      ),
    );
  }

  void _onToggleAudio(
    ToggleAudio event,
    Emitter<SettingsState> emit,
  ) {
    // Logger('SettingsBloc').fine('hasAudioOn changed to ${state.hasAudioOn}');
    print('hasAudioOn changed to ${state.hasAudioOn}');
    if (state.hasAudioOn) {
      // All sound just got muted. Audio is off.
      _audioCubit.stopAllSound();
    } else {
      if (state.hasMusicOn) {
        // All sound just got un-muted. Audio is on.
        _audioCubit.startOrResumeMusic();
      }
    }

    emit(
      state.copyWith(
        hasAudioOn: !state.hasAudioOn,
      ),
    );
  }

  void _onToggleMusic(
    ToggleMusic event,
    Emitter<SettingsState> emit,
  ) {
    if (!state.hasMusicOn) {
      // Music got turned on.
      if (state.hasAudioOn) {
        _audioCubit.startOrResumeMusic();
      }
    } else {
      // Music got turned off.
      _audioCubit.state.musicPlayer.pause();
    }

    emit(
      state.copyWith(
        hasMusicOn: !state.hasMusicOn,
      ),
    );
  }

  void _onTogglePause(
    TogglePause event,
    Emitter<SettingsState> emit,
  ) {
    emit(
      state.copyWith(
        isPaused: !state.isPaused,
      ),
    );
  }

  void _onToggleSound(
    ToggleSound event,
    Emitter<SettingsState> emit,
  ) {
    for (final player in _audioCubit.state.sfxPlayers) {
      if (player.state == PlayerState.playing) {
        player.stop();
      }
    }

    emit(
      state.copyWith(
        hasSoundsOn: !state.hasSoundsOn,
      ),
    );
  }

  @override
  Future<void> close() {
    _appLifecycleNotifier.removeListener(handleAppLifecycle);
    _audioCubit.dispose();
    return super.close();
  }

  /// Asynchronously loads values from the local storage.
  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    // Logger('SettingsController').fine(() => 'Loaded settings: $json');
    // print('Loaded settings: $json');
    return SettingsState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return state.toJson();
  }
}
