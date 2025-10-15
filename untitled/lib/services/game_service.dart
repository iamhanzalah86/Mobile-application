import 'dart:math';
import '../models/game_state.dart';

class GameService {
  final Random _random = Random();

  int generateSecretNumber() {
    return _random.nextInt(100);
  }

  String generateHint(int secretNumber) {
    int choice = _random.nextInt(3);

    if (choice == 0) {
      int low = (secretNumber - 10).clamp(0, 99);
      int high = (secretNumber + 10).clamp(0, 99);
      return "Number is between $low and $high";
    } else if (choice == 1) {
      return (secretNumber % 2 == 0) ? "Number is even" : "Number is odd";
    } else {
      return secretNumber > 50 ? "Number is greater than 50" : "Number is 50 or less";
    }
  }

  String getHintIcon(String hint) {
    if (hint.contains("between")) return "🎯";
    if (hint.contains("even") || hint.contains("odd")) return "🔢";
    return "📊";
  }

  GameState processGuess(GameState state, int guess) {
    if (guess == state.secretNumber) {
      return state.copyWith(
        lastFeedback: "🎉 Correct!",
        guessHistory: [...state.guessHistory, guess],
      );
    }

    final newLives = state.lives - 1;
    String feedback;

    if (newLives <= 0) {
      feedback = "💀 Game Over!";
    } else if (guess < state.secretNumber) {
      feedback = "📈 Too low! Try higher";
    } else {
      feedback = "📉 Too high! Try lower";
    }

    return state.copyWith(
      lives: newLives,
      lastFeedback: feedback,
      guessHistory: [...state.guessHistory, guess],
    );
  }
}