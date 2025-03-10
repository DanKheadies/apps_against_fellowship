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
  final String currentSongTitle;
  final String musicPlayerId;
  final Queue<Song> playlist;

  const AudioState({
    required this.audioStatus,
    this.currentSfxPlayer = 0,
    required this.currentSongTitle,
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
        currentSongTitle,
        musicPlayer,
        musicPlayerId,
        musicVolume,
        playlist,
        sfxPlayers,
      ];

  factory AudioState.initial() {
    String musicPlayerId = UuidV4().generate();
    List<Song> songList = List<Song>.of(songs)..shuffle();
    Queue<Song> playlist = Queue.of(songList);
    return AudioState(
      audioStatus: AudioStatus.intial,
      currentSongTitle: playlist.first.name,
      musicPlayer: AudioPlayer(
        playerId: musicPlayerId, // Need a randomized id for Hot Restart
      ),
      musicPlayerId: musicPlayerId,
      musicVolume: 0.5,
      playlist: playlist,
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
    String? currentSongTitle,
    String? musicPlayerId,
    Queue<Song>? playlist,
  }) {
    return AudioState(
      audioStatus: audioStatus ?? this.audioStatus,
      currentSfxPlayer: currentSfxPlayer ?? this.currentSfxPlayer,
      currentSongTitle: currentSongTitle ?? this.currentSongTitle,
      musicPlayer: musicPlayer ?? this.musicPlayer,
      musicPlayerId: musicPlayerId ?? this.musicPlayerId,
      musicVolume: musicVolume ?? this.musicVolume,
      playlist: playlist ?? this.playlist,
      sfxPlayers: sfxPlayers ?? this.sfxPlayers,
    );
  }
}
