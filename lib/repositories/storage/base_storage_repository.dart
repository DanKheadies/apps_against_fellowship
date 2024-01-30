import 'dart:typed_data';

import 'package:apps_against_fellowship/models/models.dart';

abstract class BaseStorageRepository {
  Future<String> getDatabaseUrl({
    required User user,
    required String imageName,
    required String bucket,
  });
  Future<String> uploadImage({
    required User user,
    required Uint8List bytes,
    required String imageName,
  });
  Future<void> removeProfileImage({
    required String url,
  });
}
