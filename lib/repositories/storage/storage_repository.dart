import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';

class StorageRepository extends BaseStorageRepository {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  Future<String> getDatabaseUrl({
    required User user,
    required String imageName,
    required String bucket,
  }) async {
    String downloadUrl =
        await storage.ref('$bucket/${user.id}/$imageName').getDownloadURL();

    return downloadUrl;
  }

  @override
  Future<void> uploadImage({
    required User user,
    required Uint8List bytes,
    required String imageName,
    required String bucket,
  }) async {
    try {
      await storage
          .ref('$bucket/${user.id}/$imageName')
          .putData(
            bytes,
          )
          .then(
            (snap) => UserRepository().updateUserPicture(
              bucket: bucket,
              imageName: imageName,
              user: user,
            ),
          );
    } catch (err) {
      print('err: $err');
    }
  }
}
