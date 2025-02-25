// import 'dart:async';
import 'dart:typed_data';

import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends HydratedBloc<UserEvent, UserState> {
  final StorageRepository _storageRepository;
  final UserRepository _userRepository;

  UserBloc({
    required StorageRepository storageRepository,
    required UserRepository userRepository,
  })  : _storageRepository = storageRepository,
        _userRepository = userRepository,
        super(const UserState()) {
    on<ClearUser>(_onClearUser);
    on<CreateDeviceId>(_onCreateDeviceId);
    on<DeleteProfilePhoto>(_onDeleteProfilePhoto);
    on<UpdateTheme>(_onUpdateTheme);
    on<UpdateUser>(_onUpdateUser);
    on<UpdateUserImage>(_onUpdateUserImage);
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

  void _onCreateDeviceId(
    CreateDeviceId event,
    Emitter<UserState> emit,
  ) {
    // TODO: update firebase (?)
    // Note: never called; still needed?
    emit(
      state.copyWith(
        user: state.user.copyWith(
          deviceId: const Uuid().v4(),
        ),
      ),
    );
  }

  void _onDeleteProfilePhoto(
    DeleteProfilePhoto event,
    Emitter<UserState> emit,
  ) async {
    emit(
      state.copyWith(
        userStatus: UserStatus.photoUpload,
      ),
    );

    try {
      _storageRepository.removeProfileImage(
        url: state.user.avatarUrl,
      );

      _userRepository.updateUser(
        user: state.user.copyWith(
          avatarUrl: '',
          updatedAt: DateTime.now(),
        ),
      );

      emit(
        state.copyWith(
          user: state.user.copyWith(
            avatarUrl: '',
            updatedAt: DateTime.now(),
          ),
          userStatus: UserStatus.loaded,
        ),
      );
    } catch (err) {
      print('err removing user photo: $err');

      emit(
        state.copyWith(
          userStatus: UserStatus.error,
        ),
      );
    }
  }

  void _onUpdateTheme(
    UpdateTheme event,
    Emitter<UserState> emit,
  ) {
    emit(
      state.copyWith(
        userStatus: UserStatus.loading,
      ),
    );

    if (event.updateFirebase) {
      _userRepository.updateUser(
        user: state.user.copyWith(
          isDarkTheme: !state.user.isDarkTheme,
        ),
      );
    }

    emit(
      state.copyWith(
        user: state.user.copyWith(
          isDarkTheme: !state.user.isDarkTheme,
          updatedAt: DateTime.now(),
        ),
        userStatus: UserStatus.loaded,
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

    User updatedUser = User.emptyUser;

    if (event.accountCreation == false) {
      updatedUser = event.user.copyWith(
        updatedAt: DateTime.now(),
      );
    } else {
      updatedUser = event.user;
    }

    try {
      if (event.updateFirebase) {
        await _userRepository.updateUser(
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

  void _onUpdateUserImage(
    UpdateUserImage event,
    Emitter<UserState> emit,
  ) async {
    emit(
      state.copyWith(
        userStatus: UserStatus.photoUpload,
      ),
    );

    if (state.user.avatarUrl != '') {
      _storageRepository.removeProfileImage(url: state.user.avatarUrl);
    }

    String avatarUrl = await _storageRepository.uploadImage(
      bytes: event.bytes,
      imageName: event.imageName,
      user: state.user,
    );

    emit(
      state.copyWith(
        user: state.user.copyWith(
          avatarUrl: avatarUrl,
          updatedAt: DateTime.now(),
        ),
        userStatus: UserStatus.loaded,
      ),
    );
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
