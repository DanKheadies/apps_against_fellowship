part of 'home_bloc.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final Game? joinedGame;
  final List<UserGame> games;
  final String error;
  final String joiningGame;
  final User user;
  final UserGame leavingGame;

  const HomeState({
    required this.isLoading,
    required this.user,
    this.games = const [],
    this.error = '',
    this.joinedGame,
    this.joiningGame = '',
    this.leavingGame = UserGame.emptyUserGame,
  });

  @override
  List<Object?> get props => [
        error,
        games,
        isLoading,
        joinedGame,
        joiningGame,
        leavingGame,
        user,
      ];

  factory HomeState.loading() {
    return const HomeState(
      isLoading: true,
      user: User.emptyUser,
      error: '',
    );
  }

  HomeState copyWith({
    bool? isLoading,
    Game? joinedGame,
    List<UserGame>? games,
    String? error,
    String? joiningGame,
    User? user,
    UserGame? leavingGame,
  }) {
    return HomeState(
      error: error ?? this.error,
      games: games ?? this.games,
      isLoading: isLoading ?? this.isLoading,
      joinedGame: joinedGame ?? this.joinedGame,
      joiningGame: joiningGame ?? this.joiningGame,
      leavingGame: leavingGame ?? this.leavingGame,
      user: user ?? this.user,
    );
  }

  factory HomeState.fromJson(Map<String, dynamic> json) {
    // print('home state fromJson');
    var list = json['games'] as List;
    List<UserGame> gamesList =
        list.map((game) => UserGame.fromJson(game)).toList();

    return HomeState(
      error: json['error'],
      games: gamesList,
      isLoading: json['isLoading'],
      joinedGame: Game.fromJson(json['joinedGame']),
      joiningGame: json['joiningGame'],
      leavingGame: UserGame.fromJson(json['leavingGame']),
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    // print('home state toJson');
    var gamesList = [];
    for (var game in games) {
      gamesList.add(game.toJson());
    }

    return {
      'error': error,
      'games': gamesList,
      'isLoading': isLoading,
      'joinedGame': joiningGame,
      'joiningGame': joiningGame,
      'leavingGame': leavingGame,
      'user': user.toJson(
        isFirebase: false,
      ),
    };
  }
}
