// import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:apps_against_fellowship/models/models.dart';

abstract class BaseDatabaseRepository {
  Future<String> getPhotoUrl({
    required String userId,
  });
  Future<User> getUser({
    required String userId,
  });
  Future<void> createUser({
    required User user,
  });
  Future<void> updateUser({
    required User user,
  });
  Future<void> updateUserPicture({
    required String imageName,
    required String bucket,
    required User user,
  });
  // Stream<User> getUserStream({
  //   required String userId,
  // });
}
