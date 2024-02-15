part of 'create_game_bloc.dart';

enum CreateGameStatus {
  error,
  initial,
  loaded,
  loading,
}

class CreateGameState extends Equatable {
  final bool draw2pick3Enabled;
  final bool pick2Enabled;
  final CreateGameStatus createGameStatus;
  final Game createdGame;
  final int playerLimit;
  final int prizesToWin;
  final KtList<CardSet> cardSets;
  final KtSet<CardSet> selectedSets;
  final String error;

  const CreateGameState({
    required this.cardSets,
    required this.createGameStatus,
    required this.selectedSets,
    this.createdGame = Game.emptyGame,
    this.draw2pick3Enabled = true,
    this.error = '',
    this.pick2Enabled = true,
    this.playerLimit = 15,
    this.prizesToWin = 7,
  });

  @override
  List<Object> get props => [
        cardSets,
        createdGame,
        createGameStatus,
        draw2pick3Enabled,
        error,
        pick2Enabled,
        playerLimit,
        prizesToWin,
        selectedSets,
      ];

  int get totalPrompts => selectedSets.sumBy((cs) => cs.prompts);
  int get totalResponses => selectedSets.sumBy((cs) => cs.responses);

  factory CreateGameState.empty() {
    return CreateGameState(
      cardSets: emptyList(),
      createGameStatus: CreateGameStatus.initial,
      selectedSets: emptySet(),
      // playerLimit: playerLimit,
      // prizesToWin: prizesToWin,
    );
  }

  CreateGameState copyWith({
    bool? draw2pick3Enabled,
    bool? pick2Enabled,
    CreateGameStatus? createGameStatus,
    Game? createdGame,
    int? playerLimit,
    int? prizesToWin,
    KtList<CardSet>? cardSets,
    KtSet<CardSet>? selectedSets,
    String? error,
  }) {
    return CreateGameState(
      cardSets: cardSets ?? this.cardSets,
      createdGame: createdGame ?? this.createdGame,
      createGameStatus: createGameStatus ?? this.createGameStatus,
      draw2pick3Enabled: draw2pick3Enabled ?? this.draw2pick3Enabled,
      error: error ?? this.error,
      pick2Enabled: pick2Enabled ?? this.pick2Enabled,
      playerLimit: playerLimit ?? this.playerLimit,
      prizesToWin: prizesToWin ?? this.prizesToWin,
      selectedSets: selectedSets ?? this.selectedSets,
    );
  }

  factory CreateGameState.fromJson(Map<String, dynamic> json) {
    return CreateGameState(
      cardSets: json['cardSets'], // TODO
      createdGame: Game.fromJson(json['createdGame']),
      createGameStatus: CreateGameStatus.values.firstWhere(
        (status) => status.name.toString() == json['createGameStatus'],
      ),
      draw2pick3Enabled: json['draw2pick3Enabled'],
      error: json['error'],
      pick2Enabled: json['pick2Enabled'],
      playerLimit: json['playerLimit'],
      prizesToWin: json['prizesToWin'],
      selectedSets: json['selectedSets'], // TODO
    );
  }

  Map<String, dynamic> toJson() {
    // TODO: KtList & KtSet (?)
    return {
      'cardSets': cardSets,
      'createdGame': createdGame,
      'createGameStatus': createGameStatus.name,
      'draw2pick3Enabled': draw2pick3Enabled,
      'error': error,
      'pick2Enabled': pick2Enabled,
      'playerLimit': playerLimit,
      'prizesToWin': prizesToWin,
      'selectedSets': selectedSets,
    };
  }
}
