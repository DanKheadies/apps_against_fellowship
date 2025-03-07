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
  final bool isPaused; // TODO: causing issues for background on Hot Reload
  final double musicVolume;

  const SettingsState({
    this.hasAudioOn = true,
    this.hasMusicOn = true,
    this.hasSoundsOn = true,
    this.isPaused = false,
    this.musicVolume = 0.5,
  });

  @override
  List<Object> get props => [
        hasAudioOn,
        hasMusicOn,
        hasSoundsOn,
        isPaused,
        musicVolume,
      ];

  SettingsState copyWith({
    bool? hasAudioOn,
    bool? hasMusicOn,
    bool? hasSoundsOn,
    bool? isPaused,
    double? musicVolume,
  }) {
    return SettingsState(
      hasAudioOn: hasAudioOn ?? this.hasAudioOn,
      hasMusicOn: hasMusicOn ?? this.hasMusicOn,
      hasSoundsOn: hasSoundsOn ?? this.hasSoundsOn,
      isPaused: isPaused ?? this.isPaused,
      musicVolume: musicVolume ?? this.musicVolume,
    );
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    // TODO: isPaused is causing issues for background on Hot Reload + App Pause
    return SettingsState(
      hasAudioOn: json['hasAudioOn'] as bool,
      hasMusicOn: json['hasMusicOn'] as bool,
      hasSoundsOn: json['hasSoundsOn'] as bool,
      // isPaused: json['isPaused'] as bool,
      musicVolume: json['musicVolume'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasAudioOn': hasAudioOn,
      'hasMusicOn': hasMusicOn,
      'hasSoundsOn': hasSoundsOn,
      'isPaused': isPaused,
      'musicVolume': musicVolume,
    };
  }
}
