import 'dart:typed_data';

import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class StorageRepository {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<String> getDatabaseUrl({
    required User user,
    required String imageName,
    required String bucket,
  }) async {
    String downloadUrl =
        await storage.ref('$bucket/${user.id}/$imageName').getDownloadURL();

    return downloadUrl;
  }

  Future<String> uploadImage({
    required User user,
    required Uint8List bytes,
    required String imageName,
  }) async {
    try {
      String downloadUrl = await storage
          .ref('userProfilePictures/${user.id}/$imageName')
          .putData(
            bytes,
          )
          .then(
            (snap) => UserRepository().updateUserPicture(
              bucket: 'userProfilePictures',
              imageName: imageName,
              user: user,
            ),
          );

      return downloadUrl;
    } catch (err) {
      print('err uploading image: $err');
      throw Exception(err);
    }
  }

  Future<void> removeProfileImage({
    required String url,
  }) async {
    try {
      firebase_storage.Reference storageDoc = storage.refFromURL(url);
      await storage.ref(storageDoc.fullPath).delete();
    } catch (err) {
      print('err: $err');
    }
  }
}
