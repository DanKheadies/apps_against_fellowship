part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class ClearUser extends UserEvent {}

class DeleteProfilePhoto extends UserEvent {}

class UpdateTheme extends UserEvent {
  final bool updateFirebase;

  const UpdateTheme({
    required this.updateFirebase,
  });

  @override
  List<Object?> get props => [
        updateFirebase,
      ];
}

class UpdateUser extends UserEvent {
  final User user;

  const UpdateUser({
    required this.user,
  });

  @override
  List<Object?> get props => [
        user,
      ];
}

class UpdateUserImage extends UserEvent {
  final Uint8List bytes;
  final String imageName;

  const UpdateUserImage({
    required this.bytes,
    required this.imageName,
  });

  @override
  List<Object?> get props => [
        bytes,
        imageName,
      ];
}
