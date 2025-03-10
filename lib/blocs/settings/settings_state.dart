part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  /// Whether or not the audio is on at all. This overrides both music
  /// and sounds (sfx).
  ///
  /// This is an important feature especially on mobile, where players
  /// expect to be able to quickly mute all the audio. Having this as
  /// a separate flag (as opposed to some kind of {off, sound, everything}
  /// enum) means that the player will not lose their [hasSoundsOn] and
  /// [hasMusicOn] preferences when they temporarily mute the game.
  final bool hasAudioOn;
  final bool hasMusicOn;
  final bool hasSoundsOn;
  final bool hasUser;
  final bool isPaused;
  final double musicVolume;
  final String previousMusicPlayerId;

  const SettingsState({
    this.hasAudioOn = true,
    this.hasMusicOn = true,
    this.hasSoundsOn = true,
    this.hasUser = false,
    this.isPaused = false,
    this.musicVolume = 0.5,
    this.previousMusicPlayerId = '',
  });

  @override
  List<Object> get props => [
        hasAudioOn,
        hasMusicOn,
        hasSoundsOn,
        hasUser,
        isPaused,
        musicVolume,
        previousMusicPlayerId,
      ];

  SettingsState copyWith({
    bool? hasAudioOn,
    bool? hasMusicOn,
    bool? hasSoundsOn,
    bool? hasUser,
    bool? isPaused,
    double? musicVolume,
    String? previousMusicPlayerId,
  }) {
    return SettingsState(
      hasAudioOn: hasAudioOn ?? this.hasAudioOn,
      hasMusicOn: hasMusicOn ?? this.hasMusicOn,
      hasSoundsOn: hasSoundsOn ?? this.hasSoundsOn,
      hasUser: hasUser ?? this.hasUser,
      isPaused: isPaused ?? this.isPaused,
      musicVolume: musicVolume ?? this.musicVolume,
      previousMusicPlayerId:
          previousMusicPlayerId ?? this.previousMusicPlayerId,
    );
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      hasAudioOn: json['hasAudioOn'], // as bool,
      hasMusicOn: json['hasMusicOn'], // as bool,
      hasSoundsOn: json['hasSoundsOn'], // as bool,
      // hasUser: json['hasUser'] as bool,
      // isPaused: json['isPaused'] as bool,
      musicVolume: json['musicVolume'], // as double,
      previousMusicPlayerId: json['previousMusicPlayerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasAudioOn': hasAudioOn,
      'hasMusicOn': hasMusicOn,
      'hasSoundsOn': hasSoundsOn,
      // 'hasUser': hasUser,
      // 'isPaused': isPaused,
      'musicVolume': musicVolume,
      'previousMusicPlayerId': previousMusicPlayerId,
    };
  }
}
