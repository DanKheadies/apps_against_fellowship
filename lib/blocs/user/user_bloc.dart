// import 'dart:async';
import 'dart:typed_data';

// import 'package:apps_against_fellowship/blocs/blocs.dart';
// import 'package:apps_against_fellowship/cubits/cubits.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends HydratedBloc<UserEvent, UserState> {
  // final AudioCubit _audioCubit;
  // final DeviceCubit _deviceCubit;
  // final SettingsBloc _settingsBloc;
  final StorageRepository _storageRepository;
  final UserRepository _userRepository;

  UserBloc({
    // required AudioCubit audioCubit,
    // required DeviceCubit deviceCubit,
    // required SettingsBloc settingsBloc,
    required StorageRepository storageRepository,
    required UserRepository userRepository,
  })  :
        // _audioCubit = audioCubit,
        // _deviceCubit = deviceCubit,
        // _settingsBloc = settingsBloc,
        _storageRepository = storageRepository,
        _userRepository = userRepository,
        super(const UserState()) {
    on<ClearUser>(_onClearUser);
    on<CreateDeviceId>(_onCreateDeviceId);
    on<DeleteProfilePhoto>(_onDeleteProfilePhoto);
    // on<UpdateTheme>(_onUpdateTheme);
    on<UpdateUser>(_onUpdateUser);
    on<UpdateUserImage>(_onUpdateUserImage);

    print('INIT USER BLOC');
    // Note: this kicked off b/c MaterialApp.router uses UserBloc's context &
    // state to inform the theme of each screen, i.e. it's wrapped in a
    // BlocBuilder<UserBloc>.
    // I could make a call to DeviceCubit & AudioCubit and kick them off here.
    // Worth a try...
    // Update: yea, this works; however, I should bring in SettingsBloc rather
    // than audioCubit
    // _audioCubit.initializeAudio();
    // _deviceCubit.setup();
    // _settingsBloc;
    // Is this enough to initialize the settingsBloc and audioCubit?
    // Yup, this works.
    // UX: should we play audio when the user doesn't have the tools to edit /
    // quiet it? Would be smarter to initialize this once they get to Home.
    // Will it continue from there, i.e. in Game?
    // Update: with our current UserBloc wrapper around MaterialApp.router, this
    // builds on app build / load up, which is OK.
    // We could use that to seed the "emptyUser" with and locally cached cubit
    // info, e.g. Brightness and Device. Then either the Subscription fed User
    // loads in and updates the local state, which should be reflect back to the
    // cubits, OR there's no state change to those data elements.
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

  // void _onUpdateTheme(
  //   UpdateTheme event,
  //   Emitter<UserState> emit,
  // ) {
  //   emit(
  //     state.copyWith(
  //       userStatus: UserStatus.loading,
  //     ),
  //   );

  //   if (event.updateFirebase) {
  //     _userRepository.updateUser(
  //       user: state.user.copyWith(
  //         isDarkTheme: !state.user.isDarkTheme,
  //       ),
  //     );
  //   }

  //   emit(
  //     state.copyWith(
  //       user: state.user.copyWith(
  //         isDarkTheme: !state.user.isDarkTheme,
  //         updatedAt: DateTime.now(),
  //       ),
  //       userStatus: UserStatus.loaded,
  //     ),
  //   );
  // }

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

    // TODO: run cloud function to update user profile pic in all current
    // games

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
