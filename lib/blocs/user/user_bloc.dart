import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends HydratedBloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const UserState()) {
    on<ClearUser>(_onClearUser);
    on<UpdateUser>(_onUpdateUser);
  }

  void _onClearUser(
    ClearUser event,
    Emitter<UserState> emit,
  ) {
    emit(
      state.copyWith(
        user: User.emptyUser,
        userStatus: UserStatus.initial,
      ),
    );
  }

  void _onUpdateUser(
    UpdateUser event,
    Emitter<UserState> emit,
  ) async {
    if (state.userStatus == UserStatus.loading) return;

    emit(
      state.copyWith(
        userStatus: UserStatus.loading,
      ),
    );

    User updatedUser = event.user.copyWith(
      updatedAt: DateTime.now(),
    );

    try {
      if (event.user != User.emptyUser) {
        await _userRepository.updateUser(
          user: updatedUser,
        );
      }

      // TODO: update homebloc

      emit(
        state.copyWith(
          user: updatedUser,
          userStatus: UserStatus.loaded,
        ),
      );
    } catch (err) {
      print('update user error: $err');
      emit(
        state.copyWith(
          user: updatedUser,
          userStatus: UserStatus.error,
        ),
      );
    }
  }

  @override
  UserState? fromJson(Map<String, dynamic> json) {
    return UserState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(UserState state) {
    return state.toJson();
  }
}
