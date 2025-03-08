part of 'audio_cubit.dart';

enum AudioStatus {
  error,
  intial,
  loaded,
  loading,
}

class AudioState extends Equatable {
  final AudioStatus audioStatus;
  final AudioPlayer musicPlayer;
  final double musicVolume;
  final int currentSfxPlayer;
  final List<AudioPlayer> sfxPlayers;
  final String musicPlayerId;
  final Queue<Song> playlist;

  const AudioState({
    required this.audioStatus,
    this.currentSfxPlayer = 0,
    required this.musicPlayer,
    required this.musicPlayerId,
    required this.musicVolume,
    required this.playlist,
    required this.sfxPlayers,
  });

  @override
  List<Object> get props => [
        audioStatus,
        currentSfxPlayer,
        musicPlayer,
        musicPlayerId,
        musicVolume,
        playlist,
        sfxPlayers,
      ];

  factory AudioState.initial() {
    String musicPlayerId = UuidV4().generate();
    return AudioState(
      audioStatus: AudioStatus.intial,
      musicPlayer: AudioPlayer(
        // playerId: 'musicPlayer', // TODO: need a randomized id for Hot Restart
        playerId: musicPlayerId,
      ),
      musicPlayerId: musicPlayerId,
      musicVolume: 0.5,
      playlist: Queue.of(List<Song>.of(songs)..shuffle),
      sfxPlayers: Iterable.generate(
        2,
        (i) => AudioPlayer(
          playerId: 'sfxPlayers$i',
        ),
      ).toList(),
    );
  }

  AudioState copyWith({
    AudioStatus? audioStatus,
    AudioPlayer? musicPlayer,
    double? musicVolume,
    int? currentSfxPlayer,
    List<AudioPlayer>? sfxPlayers,
    String? musicPlayerId,
    Queue<Song>? playlist,
  }) {
    return AudioState(
      audioStatus: audioStatus ?? this.audioStatus,
      currentSfxPlayer: currentSfxPlayer ?? this.currentSfxPlayer,
      musicPlayer: musicPlayer ?? this.musicPlayer,
      musicPlayerId: musicPlayerId ?? this.musicPlayerId,
      musicVolume: musicVolume ?? this.musicVolume,
      playlist: playlist ?? this.playlist,
      sfxPlayers: sfxPlayers ?? this.sfxPlayers,
    );
  }
}
