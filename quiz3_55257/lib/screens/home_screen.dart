import 'package:flutter/material.dart';
import '../models/flashcard_model.dart';
import '../widgets/flashcard_widget.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({Key? key}) : super(key: key);

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Flashcard> _flashcards = [];
  bool _isRefreshing = false;
  int _nextCardId = 100;

  @override
  void initState() {
    super.initState();
    _flashcards = Flashcard.getSampleCards();
  }

  int get _learnedCount => _flashcards.where((card) => card.isLearned).length;
  int get _totalCount => _flashcards.length;

  Future<void> _refreshCards() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _flashcards = Flashcard.getNewCardSet(_nextCardId);
      _nextCardId += 10;
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New quiz set loaded!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _markAsLearned(int index) {
    final card = _flashcards[index];
    setState(() {
      card.isLearned = true;
    });

    _listKey.currentState?.removeItem(
      index,
          (context, animation) => _buildRemovedItem(card, animation),
      duration: const Duration(milliseconds: 400),
    );

    setState(() {
      _flashcards.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ "${card.question}" marked as learned!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildRemovedItem(Flashcard card, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.green.shade100,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  card.question,
                  style: const TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewCard() {
    final newCard = Flashcard(
      id: '${_nextCardId++}',
      question: 'What is ${_nextCardId % 2 == 0 ? "Hot Reload" : "State Management"}?',
      answer: _nextCardId % 2 == 0
          ? 'Hot Reload allows instant code changes without app restart.'
          : 'State Management handles the flow and storage of data in your Flutter app.',
    );

    setState(() {
      _flashcards.insert(0, newCard);
    });

    _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 400));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New flashcard added!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshCards,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  '$_learnedCount of $_totalCount learned',
                  style: const TextStyle(fontSize: 16),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Flashcard Quiz',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _totalCount > 0 ? _learnedCount / _totalCount : 0,
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isRefreshing)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            if (_flashcards.isEmpty && !_isRefreshing)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.celebration,
                        size: 80,
                        color: Colors.green.shade400,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'All cards learned!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pull down to get a new quiz set',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SliverAnimatedList(
              key: _listKey,
              initialItemCount: _flashcards.length,
              itemBuilder: (context, index, animation) {
                if (index >= _flashcards.length) return const SizedBox.shrink();

                return SlideTransition(
                  position: animation.drive(
                    Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeOut)),
                  ),
                  child: FlashcardWidget(
                    card: _flashcards[index],
                    onDismissed: () => _markAsLearned(index),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewCard,
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}