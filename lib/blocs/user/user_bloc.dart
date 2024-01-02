// import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
// import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hydrated_bloc/hydrated_bloc.dart';
// import 'package:logging/logging.dart';
// import 'package:meta/meta.dart';

// import 'package:apps_against_fellowship/blocs/blocs.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends HydratedBloc<UserEvent, UserState> {
  final DatabaseRepository _databaseRepository;

  UserBloc({
    required DatabaseRepository databaseRepository,
  })  : _databaseRepository = databaseRepository,
        super(const UserState()) {
    on<UpdateUser>(_onUpdateUser);
  }

  void _onUpdateUser(
    UpdateUser event,
    Emitter<UserState> emit,
  ) async {
    if (state.userStatus == UserStatus.loading) {
      return;
    }

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
        await _databaseRepository.updateUser(
          user: updatedUser,
        );
      }

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
    // print('user bloc hydrated fromJson');
    // print(json);
    return UserState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(UserState state) {
    // print('user bloc hydrated toJson');
    // print(state);
    return state.toJson();
  }
}
