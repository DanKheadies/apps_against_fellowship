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
    String downloadUrl = await StorageRepository().getDatabaseUrl(
      bucket: bucket,
      imageName: imageName,
      user: user,
    );

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

  Future<void> createAGod(God god) async {
    try {
      DocumentReference godDoc = _firebaseFirestore.collection('gods').doc();
      // print('have doc: ${godDoc.id}');
      // In the real world, i.e. not creating GodUsopp from dummy data, the
      // subcollections would *most likely* start off as empty, but it would
      // still be good / smart to have a route that handles it, i.e. figure out
      // how to do that and then down-scale for future-use, e.g. a user creates
      // a god and then followers get added.
      await godDoc.set(
        god
            .copyWith(
              id: godDoc.id,
            )
            .toJson(isFirestore: true),
      );
      // print('God Usopp created.');

      // List of Subscribers as sub collection
      // TODO: this is its own function
      if (god.followers != null) {
        for (var follower in god.followers!) {
          DocumentReference followerDoc = godDoc.collection('followers').doc();
          await followerDoc.set(
            follower
                .copyWith(
                  id: followerDoc.id,
                )
                .toJson(
                  isTimestamp: true,
                ),
          );
          // print('follower ${follower.id}, now ${followerDoc.id} is g2g');
        }
      }

      // List of Events as sub collection
      // TODO: this is its own function
      if (god.majorActs != null) {
        for (var act in god.majorActs!) {
          DocumentReference actDoc = godDoc.collection('majorActs').doc();
          await actDoc.set(
            act
                .copyWith(
                  id: actDoc.id,
                )
                .toJson(
                  isTimestamp: true,
                ),
          );
          // print('act ${act.id}, now ${actDoc.id} is g2g');
        }
      }

      // Map of Prayers as sub collection
      // Note: the String portion helps contain the Prayers in a list, but its
      // not necessary to store it, i.e. save as a sub-collection list.
      // Then when retrieving fromSnapshot, we group by id.
      // TODO: this is its own function
      if (god.prayers != null) {
        for (var prayerList in god.prayers!.values) {
          for (var prayer in prayerList) {
            DocumentReference prayerDoc = godDoc.collection('prayers').doc();
            await prayerDoc.set(
              prayer
                  .copyWith(
                    id: prayerDoc.id,
                  )
                  .toJson(),
            );
            // print('act ${prayer.id}, now ${prayerDoc.id} is g2g');
          }
        }
      }

      // print('god is g2g');
    } catch (err) {
      print('err: $err');
      throw Exception(err);
    }
  }

  Future<void> createUser({
    required User user,
  }) async {
    if (!(await _firebaseFirestore.collection('users').doc(user.id).get())
        .exists) {
      await _firebaseFirestore.collection('users').doc(user.id).set(user.toJson(
            isFirebase: true,
          ));
    }
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
    // Update: making getUser return nullable and handling downstream, i.e.
    // in AuthBloc sub.
    return _firebaseFirestore.collection('users').doc(userId).snapshots().map(
          (snap) => snap.data() == null ? null : User.fromSnapshot(snap),
          // snap.data() == null ? User.emptyUser : User.fromSnapshot(snap),
        );
  }
}
