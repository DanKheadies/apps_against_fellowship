part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
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
