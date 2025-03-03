part of 'game_bloc.dart';

enum GameStateStatus {
  downvoting,
  // true: downvote prompt
  error,
  // true: any catch
  goodToGo,
  // true: clear submitting (never called)
  // true: done w/ downvoting prompt
  // true: downvotes updated
  // true: game updated (mostly from sub/stream or functions (?))
  // true: done kicking player
  // true: done picking winner
  // true: players updated (mostly from sub/stream or functions (?))
  // true: successfully submitted response(s)
  // true: done waving at player
  initial,
  // true: empty game state
  loading,
  // true: game (full page loader) [this one is the axe > scapel]
  // true: waiting room (spinner vs player list)
  // true: kicking a player from the game
  // UPDATE: use while functions run (i.e. the catch-all); won't affect
  // GameScreen--just the components w/in them.
  // Use in WaitingRoom to give more immediate "the game is starting" UI notice
  // than waiting to hear back from the function.
  submitting,
  // true: Judge (pick winner stuff)
  // true: player response cards (hide if submitting)
  // true: picking winner
  // true: start game
  // true: submit response
  // true: wave at player
  // UPDATE: use submitting to indicate players are / have submitted responses
  // Judge Dredd & player response stuff visiblity changes when submitting is true.
}

class GameState extends Equatable {
  final Game game;
  final GameStateStatus gameStateStatus;
  // final GameStatus gameStatus; // Note: never called; removing
  final List<Player> players;
  final List<ResponseCard> selectedCards;
  final List<String> downvotes;
  final String error;
  final String kickingPlayerId;
  final String userId;
  final bool canPickWinner;

  const GameState({
    this.canPickWinner = false,
    this.downvotes = const [],
    this.error = '',
    this.game = Game.emptyGame,
    this.gameStateStatus = GameStateStatus.initial,
    // this.gameStatus = GameStatus.waitingRoom,
    this.kickingPlayerId = '',
    this.players = const [],
    this.selectedCards = const [],
    this.userId = '',
  });

  @override
  List<Object> get props => [
        canPickWinner,
        downvotes,
        error,
        game,
        gameStateStatus,
        // gameStatus,
        kickingPlayerId,
        players,
        selectedCards,
        userId,
      ];

  GameState copyWith({
    bool? canPickWinner,
    Game? game,
    GameStateStatus? gameStateStatus,
    GameStatus? gameStatus,
    List<Player>? players,
    List<ResponseCard>? selectedCards,
    List<String>? downvotes,
    String? error,
    String? kickingPlayerId,
    String? userId,
  }) {
    return GameState(
      canPickWinner: canPickWinner ?? this.canPickWinner,
      downvotes: downvotes ?? this.downvotes,
      error: error ?? this.error,
      game: game ?? this.game,
      gameStateStatus: gameStateStatus ?? this.gameStateStatus,
      // gameStatus: gameStatus ?? this.gameStatus,
      kickingPlayerId: kickingPlayerId ?? this.kickingPlayerId,
      players: players ?? this.players,
      selectedCards: selectedCards ?? this.selectedCards,
      userId: userId ?? this.userId,
    );
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    List<Player> playersList =
        (json['players'] as List).map((player) => player as Player).toList();

    List<ResponseCard> selectedCardsList = (json['selectedCards'] as List)
        .map((card) => card as ResponseCard)
        .toList();

    List<String> downvotesList = (json['downvotes'] as List)
        .map((downvote) => downvote as String)
        .toList();

    return GameState(
      canPickWinner: json['canPickWinner'],
      downvotes: downvotesList,
      error: json['error'],
      game: Game.fromJson(json['game']),
      gameStateStatus: GameStateStatus.values.firstWhere(
        (status) => status.name.toString() == json['gameStateStatus'],
      ),
      // gameStatus: GameStatus.values.firstWhere(
      //   (status) => status.name.toString() == json['gameStatus'],
      // ),
      kickingPlayerId: json['kickingPlayerId'],
      players: playersList,
      selectedCards: selectedCardsList,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    var playersList = [];
    var selectedCardsList = [];

    for (var player in players) {
      playersList.add(player.toJson());
    }
    for (var card in selectedCards) {
      selectedCardsList.add(card.toJson());
    }

    return {
      'canPickWinner': canPickWinner,
      'downvotes': downvotes,
      'error': error,
      'game': game.toJson(),
      'gameStateStatus': gameStateStatus.name,
      // 'gameStatus': gameStatus.name,
      'kickingPlayerId': kickingPlayerId,
      'players': playersList,
      'selectedCards': selectedCardsList,
      'userId': userId,
    };
  }

  static const emptyGame = GameState(
    canPickWinner: false,
    downvotes: [],
    error: '',
    game: Game.emptyGame,
    gameStateStatus: GameStateStatus.initial,
    // gameStatus: GameStatus.waitingRoom,
    kickingPlayerId: '',
    players: [],
    selectedCards: [],
    userId: '',
  );

  bool get allResponsesSubmitted {
    if (game.turn != null &&
        game.turn?.responses != null &&
        players.isNotEmpty) {
      var allPlayersExcludingJudgeAndInactive = players
          .where(
            (p) => p.id != game.turn?.judgeId && p.isInactive != true,
          )
          .toList();
      for (var value in allPlayersExcludingJudgeAndInactive) {
        if (game.turn?.responses.keys
                    .firstWhere((e) => e == value.id, orElse: () => '') ==
                null ||
            game.turn?.responses.keys
                    .firstWhere((e) => e == value.id, orElse: () => '') ==
                '') {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }

  bool get areWeJudge => currentJudge.id == userId;
  bool get haveWeSubmittedResponse =>
      game.turn?.responses.keys.contains(userId) ?? false;
  bool get isOurGame => userId == game.ownerId;
  bool get selectCardsMeetPromptRequirement {
    PromptSpecial special = promptSpecial(game.turn?.promptCard.special ?? '');
    if (special != PromptSpecial.notSpecial) {
      if (special == PromptSpecial.draw2pick3) {
        return selectedCards.length == 3;
      } else if (special == PromptSpecial.pick2) {
        return selectedCards.length == 2;
      }
    } else {
      return selectedCards.isNotEmpty;
    }
    return false;
  }

  List<ResponseCard> get currentHand =>
      currentPlayer.hand?.where((c) => !selectedCards.contains(c)).toList() ??
      [];

  // Issue: need to handle differently when we don't have data yet..
  Player get currentJudge => players.firstWhere(
        (p) => p.id == game.turn?.judgeId,
      );

  Player get currentPlayer => players.firstWhere(
        (p) => p.id == userId,
      );
  Player get lastJudge => players.firstWhere(
        (p) => !(game.turn?.winner?.responses?.containsKey(p.id) ?? true),
      );
  Player get winner => players.firstWhere(
        (p) => p.id == game.winner,
      );

  /// Get the current prompt card text with any macros computed from the text string. For now this is just
  /// the a simple replace of the judge's name for its specific replacer text.
  /// TODO: Extract this into a tool that can take a configurable macro list for smart injecting text into prompts
  String get currentPromptText {
    var prompt = game.turn?.promptCard;
    var judge = currentJudge;
    if (prompt != null) {
      return prompt.text.replaceAll('{JUDGE_NAME}', judge.name);
    } else if (prompt != null) {
      return prompt.text;
    } else {
      return '';
    }
  }

  /// Get the current prompt card text with any macros computed from the text string. For now this is just
  /// the a simple replace of the judge's name for its specific replacer text.
  /// TODO: Extract this into a tool that can take a configurable macro list for smart injecting text into prompts
  String get lastPromptText {
    var prompt = game.turn?.winner?.promptCard;
    var judge = lastJudge;
    // if (judge != null && prompt != null) {
    if (prompt != null) {
      return prompt.text.replaceAll('{JUDGE_NAME}', judge.name);
    } else if (prompt != null) {
      return prompt.text;
    } else {
      return '';
    }
  }
}
