part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class InitializeAudio extends SettingsEvent {}

class InitializeAudioForWeb extends SettingsEvent {}

class SetMusicVolume extends SettingsEvent {
  final double level;

  const SetMusicVolume({
    required this.level,
  });

  @override
  List<Object> get props => [
        level,
      ];
}

class ToggleAudio extends SettingsEvent {}

class ToggleMusic extends SettingsEvent {}

class TogglePause extends SettingsEvent {}

class ToggleSound extends SettingsEvent {}
