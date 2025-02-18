import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firebaseFirestore;

  UserRepository({
    FirebaseFirestore? firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

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

  Future<String> updateUserPicture({
    required String imageName,
    required String bucket,
    required User user,
  }) async {
    // print('update user picture');
    String downloadUrl = await StorageRepository().getDatabaseUrl(
      bucket: bucket,
      imageName: imageName,
      user: user,
    );
    // print('succes?');

    try {
      await _firebaseFirestore.collection('users').doc(user.id).update({
        'avatarUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (err) {
      print('err updating user picture: $err');
      throw Exception(err);
    }
  }

  Future<bool> checkForUser({
    required String userId,
  }) async {
    // print('check for user..');
    return (await _firebaseFirestore.collection('users').doc(userId).get())
        .exists;
  }

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

  Future<void> createUser({
    required User user,
  }) async {
    // print('create user');
    if (!(await _firebaseFirestore.collection('users').doc(user.id).get())
        .exists) {
      // print('creating user for ${user.id}:');
      // print(user);
      await _firebaseFirestore.collection('users').doc(user.id).set(user.toJson(
            isFirebase: true,
          ));
      // bool userExist =
      //     (await _firebaseFirestore.collection('users').doc(user.id).get())
      //         .exists;
    }

    // if (userExist) {
    //   return;
    // } else {
    //   await _firebaseFirestore
    //       .collection('users')
    //       .doc(user.id)
    //       .set(user.toJson(
    //         isFirebase: true,
    //       ));
    // }
  }

  Future<void> updateUser({
    required User user,
  }) async {
    return _firebaseFirestore.collection('users').doc(user.id).set(user.toJson(
          isFirebase: true,
        ));
  }

  Stream<User?> getUserStream({
    required String userId,
  }) {
    // Update: this is the main issue when registering a new user
    // Returning the {} is what's throwing the List<dynamic> but got null issue.
    // Would be better to return an empty user and handle post-fact.
    // UPDATE: making getUser return nullable and handling downstream, i.e.
    // in AuthBloc sub.
    return _firebaseFirestore.collection('users').doc(userId).snapshots().map(
          (snap) => snap.data() == null ? null : User.fromSnapshot(snap),
          // snap.data() == null ? User.emptyUser : User.fromSnapshot(snap),
        );
  }
}
