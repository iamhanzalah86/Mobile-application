class Flashcard {
  final String id;
  final String question;
  final String answer;
  bool isLearned;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.isLearned = false,
  });

  // Sample flashcard data
  static List<Flashcard> getSampleCards() {
    return [
      Flashcard(
        id: '1',
        question: 'What is Flutter?',
        answer: 'Flutter is an open-source UI software development kit created by Google for building natively compiled applications.',
      ),
      Flashcard(
        id: '2',
        question: 'What is a Widget in Flutter?',
        answer: 'A Widget is the basic building block of Flutter UI. Everything in Flutter is a widget, from buttons to layouts.',
      ),
      Flashcard(
        id: '3',
        question: 'What is StatefulWidget?',
        answer: 'StatefulWidget is a widget that has mutable state. It can rebuild when its internal state changes.',
      ),
      Flashcard(
        id: '4',
        question: 'What is StatelessWidget?',
        answer: 'StatelessWidget is a widget that describes part of the UI which doesn\'t change over time.',
      ),
      Flashcard(
        id: '5',
        question: 'What is BuildContext?',
        answer: 'BuildContext is a handle to the location of a widget in the widget tree.',
      ),
      Flashcard(
        id: '6',
        question: 'What is setState()?',
        answer: 'setState() is a method that tells the Flutter framework that the internal state has changed and the widget needs to be rebuilt.',
      ),
      Flashcard(
        id: '7',
        question: 'What is Hot Reload?',
        answer: 'Hot Reload is a feature that allows you to see changes in your code instantly without losing the app state.',
      ),
      Flashcard(
        id: '8',
        question: 'What is Dart?',
        answer: 'Dart is the programming language used to write Flutter applications. It\'s developed by Google.',
      ),
      Flashcard(
        id: '9',
        question: 'What is pubspec.yaml?',
        answer: 'pubspec.yaml is a configuration file that manages dependencies, assets, and metadata for Flutter projects.',
      ),
      Flashcard(
        id: '10',
        question: 'What is MaterialApp?',
        answer: 'MaterialApp is a widget that wraps several widgets commonly required for Material Design applications.',
      ),
    ];
  }

  // Generate a new set of cards with different IDs
  static List<Flashcard> getNewCardSet(int startId) {
    final questions = [
      {'q': 'What is Scaffold?', 'a': 'Scaffold provides a framework implementing the basic Material Design layout structure.'},
      {'q': 'What is Container?', 'a': 'Container is a convenience widget that combines common painting, positioning, and sizing widgets.'},
      {'q': 'What is Column?', 'a': 'Column is a widget that displays its children in a vertical array.'},
      {'q': 'What is Row?', 'a': 'Row is a widget that displays its children in a horizontal array.'},
      {'q': 'What is ListView?', 'a': 'ListView is a scrollable list of widgets arranged linearly.'},
      {'q': 'What is AnimatedList?', 'a': 'AnimatedList is a scrollable list that animates items when they are inserted or removed.'},
      {'q': 'What is GestureDetector?', 'a': 'GestureDetector is a widget that detects gestures like taps, drags, and scales.'},
      {'q': 'What is InkWell?', 'a': 'InkWell is a rectangular area that responds to touch with a splash effect.'},
      {'q': 'What is Navigator?', 'a': 'Navigator manages a stack of routes (screens) and allows navigation between them.'},
      {'q': 'What is Future?', 'a': 'Future represents a potential value or error that will be available at some time in the future.'},
    ];

    return List.generate(
      10,
          (index) => Flashcard(
        id: '${startId + index}',
        question: questions[index]['q']!,
        answer: questions[index]['a']!,
      ),
    );
  }
}