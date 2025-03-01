import 'dart:async';
import 'dart:math';

import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:kt_dart/kt.dart';

class GameRepository {
  final FirebaseFirestore _firestore;
  final UserRepository _userRepository;

  GameRepository({
    FirebaseFirestore? firestore,
    required UserRepository userRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userRepository = userRepository;

  // /// To test
  // Future<void> testQuery({
  //   required String id,
  //   // required List<String> ids,
  //   // required String userId,
  //   // required dynamic user,
  // }) async {
  //   // var snapshot = await _firestore
  //   //     .collectionGroup('players')
  //   //     .where('id', isEqualTo: userId)
  //   //     .get()
  //   //     .then(
  //   //   (res) {
  //   //     print('res:');
  //   //     print(res);
  //   //   },
  //   //   onError: (err) => print(err),
  //   // );
  //   // var snapshot = await _firestore
  //   //     .collectionGroup('responses')
  //   //     .where('cid', whereIn: ids)
  //   //     .get()
  //   //     .then(
  //   //   (res) {
  //   //     print('res:');
  //   //     print(res);
  //   //   },
  //   //   onError: (err) => print(err),
  //   // );
  //   var snapshot = await _firestore
  //       .collectionGroup('prompts')
  //       .where('cid', isEqualTo: id)
  //       .get()
  //       .then(
  //     (res) {
  //       print('res:');
  //       print(res);
  //     },
  //     onError: (err) => print(err),
  //   );
  //   print(snapshot);
  // }

  /// Create a new game with the provided list of card sets
  Future<Game> createGame(
    User user,
    KtSet<CardSet> cardSets, {
    int prizesToWin = Game.initPrizesToWin,
    int playerLimit = Game.initPlayerLimit,
    bool pick2Enabled = true,
    bool draw2Pick3Enabled = true,
  }) async {
    // Creates an empty document w/ id
    var newGameDoc = _firestore.collection('games').doc();

    // Constructs the game object
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

    // Writes to the document with the game data
    await newGameDoc.set(game.toJson());

    // Now add yourself as a player to the game
    await _addSelfToGame(
      gameDocumentId: newGameDoc.id, // Firebase
      gameId: game.gameId, // 5-digit
      me: user,
    );

    return game;
  }

  /// Join an existing game using the [gameId] game id code
  Future<Game> joinGame(
    String gameDocumentId,
    String gameId,
    User user,
  ) async {
    return await _addSelfToGame(
      gameDocumentId: gameDocumentId,
      gameId: gameId,
      me: user,
    );
    // try {
    //   return await _addSelfToGame(
    //     gameDocumentId: gameDocumentId,
    //     gameId: gameId,
    //     me: user,
    //   );
    // } catch (err) {
    //   throw Exception('join game err: $err');
    // }
  }

  /// Find an existing game using the [gameId] game id code
  Future<Game> findGame(
    String gameId,
  ) async {
    var snapshots = await _firestore
        .collection('games')
        .where(
          'gameId',
          isEqualTo: gameId.toUpperCase(),
        )
        .limit(1)
        .get();

    if (snapshots.docs.isNotEmpty) {
      var document = snapshots.docs.first;
      return Game.fromSnapshot(document);
    } else {
      throw 'Unable to find a game for $gameId';
    }
  }

  /// Get a game by it's actual document id
  Future<Game> getGame(
    String gameDocumentId,
    User user, {
    bool andJoin = false,
  }) async {
    // print('getting game..');
    // print(gameDocumentId);
    var gameDocument = _firestore.collection('games').doc(gameDocumentId);
    // print('has gameDoc');

    try {
      // print('trying for snapshot');
      var snapshot = await gameDocument.get();
      // print('should be g2g, going to convert');
      return Game.fromSnapshot(snapshot);
    } catch (e) {
      if (e is PlatformException && andJoin) {
        try {
          return await _addSelfToGame(
            gameDocumentId: gameDocumentId,
            gameId: gameDocumentId,
            me: user,
          );
        } catch (e, st) {
          print("Error joining game: $e\n$st");
        }
      }
    }

    return Game.emptyGame;
  }

  /// Leave a game. This will flag the 'player' on the game as 'inActive'
  Future<void> leaveGame(User user, UserGame game) async {
    // if (game.gameState.gameStatus == GameStatus.completed) {
    if (game.gameStatus == GameStatus.completed) {
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
        HttpsCallableResult response =
            await FirebaseFunctions.instance.httpsCallable('leaveGame').call({
          'game_id': game.id,
          'uid': user.id,
        });
        print("Game left! ${response.data}");
      } catch (err) {
        print('leave game cloud functions error: $err');
      }
    }
  }

  /// Return a list of games that you have joined in the past
  Stream<List<UserGame>> observeJoinedGames(User user) {
    // print('observe');
    // print(user);
    return _firestore
        .collection('users')
        .doc(user.id)
        .collection('games')
        .snapshots()
        .map((querySnapshot) =>
            querySnapshot.docs.map((e) => UserGame.fromSnapshot(e)).toList());
  }

  /// Observe any changes to a game state by it's [gameDocumentId]
  Stream<Game> observeGame(String gameDocumentId) {
    var document = _firestore.collection('games').doc(gameDocumentId);

    return document.snapshots().map((snapshot) => Game.fromSnapshot(snapshot));
  }

  /// Observe any changes to the players of a game by it's [gameDocumentId]
  Stream<List<Player>> observePlayers(String gameDocumentId) {
    var collection = _firestore
        .collection('games')
        .doc(gameDocumentId)
        .collection('players');

    return collection.snapshots().map((snapshots) =>
        snapshots.docs.map((e) => Player.fromSnapshot(e)).toList());
  }

  /// Observe any changes to the downvote tally by it's [gameDocumentId]
  Stream<List<String>> observeDownvotes(String gameDocumentId) {
    var collection = _firestore
        .collection('games')
        .doc(gameDocumentId)
        .collection('downvotes')
        .doc('tally');

    return collection.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data()!.isNotEmpty) {
        return List<String>.from(snapshot.data()!['votes'] ?? []);
      } else {
        return [];
      }
    });
  }

  /// Add Rando Cardrissian to the game
  /// [gameDocumentId] the game to add him to
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

  /// Start a game that is in it's [GameState.waitingRoom] state
  /// The gamescreen should pick up the game state change and update the UI
  /// accordingly
  Future<void> startGame(String gameDocumentId, String uid) async {
    print('start game call');
    try {
      dynamic response =
          await FirebaseFunctions.instance.httpsCallable('startGame').call({
        'game_id': gameDocumentId,
        'uid': uid,
      });
      print("Start game Successful!");
      print(response);
    } catch (err) {
      print('error starting game: $err');
    }
  }

  /// Submit your responses for the current turn, if you are not a judge, and
  /// you haven't submitted your response already
  Future<void> submitResponse(
    String gameDocumentId,
    String uid,
    List<ResponseCard> cards,
  ) async {
    dynamic response =
        await FirebaseFunctions.instance.httpsCallable('submitResponses').call({
      'game_id': gameDocumentId,
      'uid': uid,
      'indexed_responses': cards.asMap().map(
            (key, value) => MapEntry(
              key.toString(),
              value.cardId,
            ),
          )
    });
    print("Responses Submitted! $response");
  }

  /// Downvote the current prompt card. If enough downvotes are casted
  /// then a new prompt is drawn for this turn and the current judge remains
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

  /// Wave at a player to re-engage them in the game. Optionally provide a [message] to send to the
  /// user.
  Future<void> waveAtPlayer(
    String gameDocumentId,
    String playerId,
    String uid, [
    String? message,
  ]) async {
    dynamic response =
        await FirebaseFunctions.instance.httpsCallable('wave').call({
      'game_id': gameDocumentId,
      'player_id': playerId,
      'uid': uid,
      if (message != null) 'message': message,
    });
    print("Wave sent to player successfully! $response");
  }

  /// Re-deal your hand in exchange for one prize card, if you have one
  Future<void> reDealHand(String gameDocumentId, String uid) async {
    dynamic response =
        await FirebaseFunctions.instance.httpsCallable('reDealHand').call({
      'game_id': gameDocumentId,
      'uid': uid,
    });
    print("Hand re-dealt successfully! $response");
  }

  //////////////////////
  // Judge Methods
  //////////////////////

  /// Pick the winner of the turn that you are judging. This will fail if:
  /// A. You are not the judge
  /// B. All responses are not in yet
  /// C. The turn hasn't been rotated yet and your previous pick still persists
  Future<void> pickWinner(
    String gameDocumentId,
    String playerId,
    String uid,
  ) async {
    dynamic response =
        await FirebaseFunctions.instance.httpsCallable('pickWinner').call({
      'game_id': gameDocumentId,
      'player_id': playerId,
      'uid': uid,
    });
    print("Winner picked Successful! $response");
  }

  Future<Game> _addSelfToGame({
    required String gameDocumentId, // Firebase's documentId
    required String gameId, // 5-digit gameId
    required User me,
  }) async {
    var user = await _userRepository.getUser(
      userId: me.id,
    );

    HttpsCallableResult response =
        await FirebaseFunctions.instance.httpsCallable('joinGame').call(
      {
        'game_doc_id': gameDocumentId,
        'game_id': gameId.toUpperCase(),
        'uid': user.id,
        'name': user.name,
        'avatar': user.avatarUrl,
      },
    );

    var jsonResponse = Map<String, dynamic>.from(response.data);
    var game = Game.fromJson(jsonResponse);
    game.copyWith(
      gameId: jsonResponse['id'],
    );

    return game;
  }

  //////////////////////
  // Owner Methods
  //////////////////////

  /// Kick a player from a game, this will only work if you are the owner of the game
  Future<void> kickPlayer(
    String gameDocumentId,
    String playerId,
    String uid,
  ) async {
    HttpsCallableResult response =
        await FirebaseFunctions.instance.httpsCallable('kickPlayer').call({
      'game_id': gameDocumentId,
      'player_id': playerId,
      'uid': uid,
    });
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
