import 'dart:async';

import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/v4.dart';
// import 'package:uuid/v4.dart';

part 'device_state.dart';

class DeviceCubit extends HydratedCubit<DeviceState> {
  final DeviceRepository _deviceRepository;
  final FirebaseMessaging _firebaseMessaging;
  StreamSubscription? _tokenSubscription;

  DeviceCubit({
    required DeviceRepository deviceRepository,
    FirebaseMessaging? firebaseMessaging,
  })  : _deviceRepository = deviceRepository,
        _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance,
        super(DeviceState.initial());

  Future<void> checkAndUpdateToken({bool force = false}) async {
    print('dev cubit check and update');
    // String? token = await _firebaseMessaging.getAPNSToken(); // TBD
    // TODO: need to configure Firebase, iOS, and Android first
    // String? token = await _firebaseMessaging.getToken(); // TODO: web (?)
    // print('token: $token');
    // if ((token != null && token != state.token) || force) {
    //   print('FCM Token is different from what is stored, updating device...');
    //   try {
    //     _deviceRepository.updatePushToken(
    //       deviceId: state.deviceId,
    //       token: token!,
    //     );

    //     emit(
    //       state.copyWith(
    //         token: token,
    //       ),
    //     );
    //   } catch (err) {
    //     print('update token error: $err');
    //   }
    // }
  }

  // Note: moved to FirebaseNotifications file
  // void checkPermissions() {
  //   print('dev cubit check perm');
  //   _firebaseMessaging.requestPermission(
  //     alert: true,
  //     announcement: true,
  //     badge: true,
  //     sound: true,
  //   );
  // }

  void setup() {
    print('dev cubit setup');
    // Setup firebase messaging
    _tokenSubscription = _firebaseMessaging.onTokenRefresh.listen((token) {
      print('token sub online');
      try {
        _deviceRepository.updatePushToken(
          deviceId: state.deviceId,
          token: token,
        );

        emit(
          state.copyWith(
            token: token,
          ),
        );
      } catch (err) {
        print('token sub - devRepo update token error: $err');
      }
    });

    // Initialize local token
    checkAndUpdateToken();
  }

  @override
  Future<void> close() {
    _tokenSubscription?.cancel();
    _tokenSubscription = null;
    return super.close();
  }

  @override
  DeviceState? fromJson(Map<String, dynamic> json) {
    print('device cubit hydrated fromJson');
    return DeviceState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(DeviceState state) {
    return state.toJson();
  }
}
