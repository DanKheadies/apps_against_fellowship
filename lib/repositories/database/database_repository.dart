import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';

class DatabaseRepository extends BaseDatabaseRepository {
  final FirebaseFirestore _firebaseFirestore;

  DatabaseRepository({
    FirebaseFirestore? firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<String> getPhotoUrl({
    required String userId,
  }) async {
    DocumentSnapshot snap =
        await _firebaseFirestore.collection('users').doc(userId).get();

    if (snap.data() == null) {
      return '';
    }

    return User.fromSnapshot(snap).avatarUrl;
  }

  @override
  Future<User> getUser({
    required String userId,
  }) async {
    DocumentSnapshot snap =
        await _firebaseFirestore.collection('users').doc(userId).get();

    if (snap.data() == null) {
      return User.emptyUser;
    }

    return User.fromSnapshot(snap);
  }

  @override
  Future<void> createUser({
    required User user,
  }) async {
    bool userExist =
        (await _firebaseFirestore.collection('users').doc(user.id).get())
            .exists;

    if (userExist) {
      return;
    } else {
      await _firebaseFirestore
          .collection('users')
          .doc(user.id)
          .set(user.toJson());
    }
  }

  @override
  Future<void> updateUser({
    required User user,
  }) async {
    return _firebaseFirestore
        .collection('users')
        .doc(user.id)
        .update(user.toSnap());
  }

  @override
  Future<void> updateUserPicture({
    required String imageName,
    required String bucket,
    required User user,
  }) async {
    String downloadUrl = await StorageRepository().getDatabaseUrl(
      bucket: bucket,
      imageName: imageName,
      user: user,
    );

    return _firebaseFirestore.collection('users').doc(user.id).update({
      // 'photoUrl': FieldValue.arrayUnion([downloadUrl]),
      'avatarUrl': downloadUrl,
    });
  }

  // @override
  // Stream<User> getUserStream({
  //   required String userId,
  // }) {
  //   // Update: this is the main issue when registering a new user
  //   // Returning the {} is what's throwing the List<dynamic> but got null issue.
  //   // Would be better to return an empty user and handle post-fact.
  //   return _firebaseFirestore.collection('users').doc(userId).snapshots().map(
  //         (snap) =>
  //             snap.data() == null ? User.emptyUser : User.fromSnapshot(snap),
  //       );
  // }
}
