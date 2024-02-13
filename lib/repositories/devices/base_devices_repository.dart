abstract class BaseDevicesRepository {
  /// Update the user's push token.
  Future<void> updatePushToken({
    required String deviceId,
    required String token,
  });
}
