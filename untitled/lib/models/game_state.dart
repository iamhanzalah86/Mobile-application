class GameState {
  static const int maxLives = 6;

  final int secretNumber;
  final int lives;
  final bool hintUsed;
  final String lastFeedback;
  final List<int> guessHistory;

  GameState({
    required this.secretNumber,
    this.lives = maxLives,
    this.hintUsed = false,
    this.lastFeedback = "Guess a number between 0-99",
    this.guessHistory = const [],
  });

  GameState copyWith({
    int? secretNumber,
    int? lives,
    bool? hintUsed,
    String? lastFeedback,
    List<int>? guessHistory,
  }) {
    return GameState(
      secretNumber: secretNumber ?? this.secretNumber,
      lives: lives ?? this.lives,
      hintUsed: hintUsed ?? this.hintUsed,
      lastFeedback: lastFeedback ?? this.lastFeedback,
      guessHistory: guessHistory ?? this.guessHistory,
    );
  }

  bool get isGameOver => lives <= 0;
  bool get hasGuesses => guessHistory.isNotEmpty;
}