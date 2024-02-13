import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:kt_dart/kt.dart';

import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';

class GameRepository extends BaseGameRepository {
  final FirebaseFirestore _firestore;
  final UserRepository _userRepository;

  GameRepository({
    FirebaseFirestore? firestore,
    required UserRepository userRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userRepository = userRepository;

  @override
  Future<Game> createGame(
    User user,
    KtSet<CardSet> cardSets, {
    int prizesToWin = Game.initPrizesToWin,
    int playerLimit = Game.initPlayerLimit,
    bool pick2Enabled = true,
    bool draw2Pick3Enabled = true,
  }) async {
    var newGameDoc = _firestore.collection('games').doc();
    var game = Game(
      cardSets: cardSets.map((c) => c.id).asList().toSet(),
      gameId: generateId(
        length: 5,
      ),
      gameStatus: GameStatus.waitingRoom,
      id: newGameDoc.id,
      ownerId: user.id,
      draw2Pick3Enabled: draw2Pick3Enabled,
      pick2Enabled: pick2Enabled,
      playerLimit: playerLimit,
      prizesToWin: prizesToWin,
    );

    await newGameDoc.set(game.toJson());

    // Now add yourself as a player to the game
    await _addSelfToGame(
      gameDocumentId: newGameDoc.id,
      gid: user.id,
      me: user,
    );

    return game;
  }

  @override
  Future<Game> joinGame(
    String gid,
    User user,
  ) async {
    return await _addSelfToGame(
      gameDocumentId: gid,
      gid: user.id,
      me: user,
    );
  }

  @override
  Future<Game> findGame(
    String gid,
  ) async {
    var snapshots = await _firestore
        .collection('games')
        .where(
          'gid',
          isEqualTo: gid.toUpperCase(),
        )
        .limit(1)
        .get();

    if (snapshots.docs.isNotEmpty) {
      var document = snapshots.docs.first;
      return Game.fromSnapshot(document);
    } else {
      throw 'Unable to find a game for $gid';
    }
  }

  @override
  Future<Game> getGame(
    String gameDocumentId,
    User user, {
    bool andJoin = false,
  }) async {
    var gameDocument = _firestore.collection('games').doc(gameDocumentId);

    try {
      var snapshot = await gameDocument.get();
      return Game.fromSnapshot(snapshot);
    } catch (e) {
      if (e is PlatformException && andJoin) {
        try {
          return await _addSelfToGame(
            gameDocumentId: gameDocumentId,
            gid: gameDocumentId,
            me: user,
          );
        } catch (e, st) {
          print("Error joining game: $e\n$st");
        }
      }
    }
    print('empty game');
    return Game.emptyGame;
  }

  @override
  Future<void> leaveGame(User user, UserGame game) async {
    if (game.gameState.gameStatus == GameStatus.completed) {
      // We should just delete the usergame ourselfs
      await _firestore
          .collection('users')
          .doc(user.id)
          .collection('games')
          .doc(game.id)
          .delete();
      print("Game already completed, so we just deleted the reference");
    } else {
      try {
        HttpsCallableResult response = await FirebaseFunctions.instance
            .httpsCallable('leaveGame')
            .call(<String, dynamic>{
          'game_id': game.id,
        });
        print("Game left! ${response.data}");
      } catch (err) {
        print('leave game cloud functions error: $err');
      }
    }
  }

  @override
  Stream<List<UserGame>> observeJoinedGames(User user) {
    return _firestore
        .collection('users')
        .doc(user.id)
        .collection('games')
        .snapshots()
        .map((querySnapshot) =>
            querySnapshot.docs.map((e) => UserGame.fromSnapshot(e)).toList());
  }

  @override
  Stream<Game> observeGame(String gameDocumentId) {
    var document = _firestore.collection('games').doc(gameDocumentId);

    return document.snapshots().map((snapshot) => Game.fromSnapshot(snapshot));
  }

  @override
  Stream<List<Player>> observePlayers(String gameDocumentId) {
    var collection = _firestore
        .collection('games')
        .doc(gameDocumentId)
        .collection('players');

    return collection.snapshots().map((snapshots) =>
        snapshots.docs.map((e) => Player.fromSnapshot(e)).toList());
  }

  @override
  Stream<List<String>> observeDownvotes(String gameDocumentId) {
    var collection = _firestore
        .collection('games')
        .doc(gameDocumentId)
        .collection('downvotes')
        .doc('tally');

    return collection.snapshots().map((snapshot) {
      if (snapshot.data()!.isNotEmpty) {
        return List<String>.from(snapshot.data()!['votes'] ?? []);
      } else {
        return [];
      }
    });
  }

  @override
  Future<void> addRandoCardrissian(String gameDocumentId) async {
    var document = _firestore
        .collection('games')
        .doc(gameDocumentId)
        .collection('players')
        .doc('rando-cardrissian');

    var rando = const Player(
      id: 'rando-cardrissian',
      name: "Rando Cardrissian",
      avatarUrl: null,
      isRandoCardrissian: true,
    );

    await document.set(rando.toJson());
  }

  @override
  Future<void> startGame(String gameDocumentId) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('startGame');
    dynamic response =
        await callable.call(<String, dynamic>{'game_id': gameDocumentId});
    print("Start game Successful! $response");
  }

  @override
  Future<void> submitResponse(
      String gameDocumentId, List<ResponseCard> cards) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('submitResponses');
    dynamic response = await callable.call(<String, dynamic>{
      'game_id': gameDocumentId,
      'indexed_responses': cards.asMap().map(
            (key, value) => MapEntry(
              key.toString(),
              value.cardId,
            ),
          )
    });
    print("Responses Submitted! $response");
  }

  @override
  Future<void> downVoteCurrentPrompt(
    String gameDocumentId,
    User user,
  ) async {
    var gameDocument = _firestore
        .collection('games')
        .doc(gameDocumentId)
        .collection('downvotes')
        .doc('tally');

    var snapshot = await gameDocument.get();

    if (snapshot.exists) {
      await gameDocument.update({
        'votes': FieldValue.arrayUnion([user.id])
      });
    } else {
      await gameDocument.set({
        'votes': [user.id]
      });
    }
  }

  @override
  Future<void> waveAtPlayer(
    String gameDocumentId,
    String playerId, [
    String? message,
  ]) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('wave');
    dynamic response = await callable.call(<String, dynamic>{
      'game_id': gameDocumentId,
      'player_id': playerId,
      if (message != null) 'message': message,
    });
    print("Wave sent to player successfully! $response");
  }

  @override
  Future<void> reDealHand(String gameDocumentId) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('reDealHand');
    dynamic response =
        await callable.call(<String, dynamic>{'game_id': gameDocumentId});
    print("Hand re-dealt successfully! $response");
  }

  @override
  Future<void> pickWinner(String gameDocumentId, String playerId) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('pickWinner');
    dynamic response = await callable.call(
        <String, dynamic>{'game_id': gameDocumentId, 'player_id': playerId});
    print("Winner picked Successful! $response");
  }

  Future<Game> _addSelfToGame({
    required String gameDocumentId,
    required String gid,
    required User me,
  }) async {
    var user = await _userRepository.getUser(
      userId: me.id,
    );

    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('joinGame');
    HttpsCallableResult response = await callable.call(<String, dynamic>{
      'game_id': gameDocumentId,
      'gid': gid.toUpperCase(),
      'name': user.name,
      'avatar': user.avatarUrl,
    });

    var jsonResponse = Map<String, dynamic>.from(response.data);
    var game = Game.fromJson(jsonResponse);
    game.copyWith(
      gameId: jsonResponse['id'],
    );
    return game;
  }

  @override
  Future<void> kickPlayer(String gameDocumentId, String playerId) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('kickPlayer');
    HttpsCallableResult response = await callable.call(
        <String, dynamic>{'game_id': gameDocumentId, 'player_id': playerId});
    print("Player kicked! ${response.data}");
  }

  String generateId({int length = 7}) {
    String source = "ACEFHJKLMNPQRTUVWXY3479";
    StringBuffer builder = StringBuffer();
    for (var i = 0; i < length; i++) {
      builder.write(source[Random().nextInt(source.length)]);
    }
    return builder.toString();
  }
}
