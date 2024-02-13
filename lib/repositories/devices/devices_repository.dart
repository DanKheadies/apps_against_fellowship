import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:apps_against_fellowship/repositories/repositories.dart';

class DevicesRepository extends BaseDevicesRepository {
  final auth.FirebaseAuth _firebaseAuth;
  final DeviceInfoPlugin _deviceInfoPlugin;
  final FirebaseFirestore _firestore;

  DevicesRepository({
    DeviceInfoPlugin? deviceInfoPlugin,
    auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin(),
        _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> updatePushToken({
    required String deviceId,
    required String token,
  }) async {
    // TODO: see where deviceId and token come from
    // Update state too

    var currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      // If current token is not null, attempt to pull existing device info and copy it to new push token
      var document = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('devices')
          .doc(deviceId);

      var snapshot = await document.get();
      if (snapshot.exists) {
        await document.update({"token": token});
      } else {
        var newDevice = await _createNewDevice(token);
        await document.set(newDevice);
      }
    }
  }

  Future<Map<String, dynamic>> _createNewDevice(String token) async {
    return {
      "token": token,
      "platform": _getPlatform(),
      "info": await _getDeviceInfo(),
      "createdAt": Timestamp.now(),
      "updatedAt": Timestamp.now()
    };
  }

  String _getPlatform() {
    if (kIsWeb) {
      return "web";
    } else {
      if (Platform.isAndroid) {
        return "android";
      } else if (Platform.isIOS) {
        return "ios";
      } else {
        return "other";
      }
    }
  }

  Future<String> _getDeviceInfo() async {
    if (kIsWeb) {
      return "Web";
    } else {
      if (Platform.isAndroid) {
        var androidInfo = await _deviceInfoPlugin.androidInfo;
        return "${androidInfo.manufacturer}/${androidInfo.model}/${androidInfo.product}/isPhysicalDevice(${androidInfo.isPhysicalDevice})/sdk(${androidInfo.version.sdkInt})";
      } else {
        var iosInfo = await _deviceInfoPlugin.iosInfo;
        return "${iosInfo.model}/${iosInfo.systemName}/${iosInfo.systemVersion}";
      }
    }
  }
}
