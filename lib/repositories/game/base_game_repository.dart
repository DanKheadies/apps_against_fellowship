import 'package:kt_dart/collection.dart';

import 'package:apps_against_fellowship/models/models.dart';

abstract class BaseGameRepository {
  /// Create a new game with the provided list of card sets
  Future<Game> createGame(
    User user,
    KtSet<CardSet> cardSets, {
    int prizesToWin = Game.initPrizesToWin,
    int playerLimit = Game.initPlayerLimit,
    bool pick2Enabled = true,
    bool draw2Pick3Enabled = true,
  });

  /// Join an existing game using the [gid] game id code
  Future<Game> joinGame(String gid, User user);

  /// Find an existing game using the [gid] game id code
  Future<Game> findGame(String gid);

  /// Get a game by it's actual document id
  Future<Game> getGame(
    String gameDocumentId,
    User user, {
    bool andJoin = false,
  });

  /// Leave a game. This will flag the 'player' on the game as 'inActive'
  Future<void> leaveGame(User user, UserGame game);

  /// Return a list of games that you have joined in the past
  Stream<List<UserGame>> observeJoinedGames(User user);

  /// Observe any changes to a game state by it's [gameDocumentId]
  Stream<Game> observeGame(String gameDocumentId);

  /// Observe any changes to the players of a game by it's
  /// [gameDocumentId]
  Stream<List<Player>> observePlayers(String gameDocumentId);

  /// Observe any changes to the downvote tally by it's [gameDocumentId]
  Stream<List<String>> observeDownvotes(String gameDocumentId);

  /// Add Rando Cardrissian to the game
  /// [gid] the game to add him to
  Future<void> addRandoCardrissian(String gameDocumentId);

  /// Start a game that is in it's [GameState.waitingRoom] state
  /// The gamescreen should pick up the game state change and update the UI
  /// accordingly
  Future<void> startGame(String gameDocumentId);

  /// Submit your responses for the current turn, if you are not a judge, and
  /// you haven't submitted your response already
  Future<void> submitResponse(String gameDocumentId, List<ResponseCard> cards);

  /// Downvote the current prompt card. If enough downvotes are casted
  /// then a new prompt is drawn for this turn and the current judge remains
  Future<void> downVoteCurrentPrompt(String gameDocumentId, User user);

  /// Wave at a player to re-engage them in the game. Optionally provide a [message] to send to the
  /// user.
  Future<void> waveAtPlayer(
    String gameDocumentId,
    String playerId, [
    String? message,
  ]);

  /// Re-deal your hand in exchange for one prize card, if you have one
  Future<void> reDealHand(String gameDocumentId);

  //////////////////////
  // Judge Methods
  //////////////////////

  /// Pick the winner of the turn that you are judging. This will fail if:
  /// A. You are not the judge
  /// B. All responses are not in yet
  /// C. The turn hasn't been rotated yet and your previous pick still persists
  Future<void> pickWinner(String gameDocumentId, String playerId);

  //////////////////////
  // Owner Methods
  //////////////////////

  /// Kick a player from a game, this will only work if you are the owner of the game
  Future<void> kickPlayer(String gameDocumentId, String playerId);
}
