import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/v4.dart';
// import 'package:logging/logging.dart';

part 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  AudioCubit() : super(AudioState.initial());

  // static final log = Logger('AudioCubit');

  Future<void> playCurrentSongInPlaylist() async {
    // log.info('Playing ${state.playlist.first} now.');
    print('Playing ${state.playlist.first} now.');
    try {
      await state.musicPlayer.play(
        AssetSource(
          'music/${state.playlist.first.filename}',
        ),
      );
      emit(
        state.copyWith(
          currentSongTitle: state.playlist.first.name,
        ),
      );
    } catch (err) {
      // log.severe(
      //   'Could not play song ${state.playlist.first}',
      //   err,
      // );
      print('Could not play song ${state.playlist.first}');
      print(err);
    }
  }

  void prevSong() {
    print('play prev song');
    state.musicPlayer.stop();
    state.playlist.addFirst(state.playlist.removeLast());
    playCurrentSongInPlaylist();
  }

  void nextSong() {
    print('play next song');
    state.musicPlayer.stop();
    state.playlist.addLast(state.playlist.removeFirst());
    playCurrentSongInPlaylist();
  }

  Future<void> preloadSfx() async {
    // log.info('Preloading sound effects');
    // print('Preloading sound effects');
    await AudioCache.instance.loadAll(
      SfxType.values
          .expand(soundTypeToFilename)
          .map((path) => 'sfx/$path')
          .toList(),
    );
  }

  // Gets and returns musicPlayerIds to release current running audio players
  // via Hot Restart/Load.
  // Note: if on web and changing / restarting before music can pause,
  // the music player will continue and a full restart is required.
  String initializeAudio(String previousMusicPlayerId) {
    // print('initializing audio');
    // print('releasing music player: $previousMusicPlayerId');
    releaseMusicPlayer(previousMusicPlayerId);

    // log.info('Initialize music repeat.');
    // print('Initialize music repeat.');
    state.musicPlayer.onPlayerComplete.listen(handleSongFinished);
    unawaited(preloadSfx());

    // print('returning music player: ${state.musicPlayerId}');
    return state.musicPlayerId;
  }

  void handleSongFinished(void _) {
    // log.info('Last song finished playing.');
    // print('Last song finished playing.');
    state.playlist.addLast(state.playlist.removeFirst());
    playCurrentSongInPlaylist();
  }

  void playSfx(
    SfxType type,
    SettingsState settings,
  ) {
    final audioOn = settings.hasAudioOn;
    if (!audioOn) {
      // log.fine(() => 'Ignoring player sound ($type) because audio is muted.');
      // print('Ignoring player sound ($type) because audio is muted.');
      return;
    }
    final soundsOn = settings.hasSoundsOn;
    if (!soundsOn) {
      // log.fine(() =>
      //     'Ignoring playing sound ($type) because sounds are turned off.');
      // print('Ignoring playing sound ($type) because sounds are turned off.');
      return;
    }

    // log.fine(() => 'Playing sound: $type');
    // print('Playing sound: $type');
    final options = soundTypeToFilename(type);
    final filename = options[Random().nextInt(options.length)];
    // log.fine(() => 'Chosen filename: $filename');
    // print('Chosen filename: $filename');

    final currentPlayer = state.sfxPlayers[state.currentSfxPlayer];

    currentPlayer.play(
      AssetSource('sfx/$filename'),
      volume: soundTypeToVolume(type),
    );

    emit(
      state.copyWith(
          currentSfxPlayer:
              (state.currentSfxPlayer + 1) % state.sfxPlayers.length),
    );
  }

  void releaseMusicPlayer(String previousMusicPlayerId) {
    AudioPlayer(playerId: previousMusicPlayerId).release();
  }

  void setMusicVolume(double level) {
    state.musicPlayer.setVolume(level);
    emit(
      state.copyWith(
        musicVolume: level,
      ),
    );
  }

  // TODO: (on web at least) the song starts from the beginning when you nav
  // away and come back; might need to track a duration /
  void startOrResumeMusic() async {
    // print('start or resume');
    if (state.musicPlayer.source == null) {
      // log.info('No music source set. '
      //     'Start playing the current song in playlist.');
      // print('No music source set. '
      //     'Start playing the current song in playlist.');
      await playCurrentSongInPlaylist();
      return;
    }

    // log.info('Resuming paused music.');
    // print('Resuming paused music.');
    try {
      state.musicPlayer.resume();
    } catch (err) {
      // log.severe('Error resuming music', err);
      print('Error resuming music');
      print(err);
      playCurrentSongInPlaylist();
    }
  }

  void stopAllSound() {
    // log.info('Stopping all sound.');
    // print('Stopping all sound.');
    state.musicPlayer.pause();
    for (final player in state.sfxPlayers) {
      player.stop();
    }
  }

  void dispose() {
    // log.info('Dispose.');
    // print('Dispose');
    stopAllSound();
    state.musicPlayer.dispose();
    for (final player in state.sfxPlayers) {
      player.dispose();
    }
  }
}
