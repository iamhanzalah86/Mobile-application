import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import '../models/game_state.dart';
import '../services/game_service.dart';
import '../widgets/background_container.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../widgets/lives_indicator.dart';
import '../widgets/dialogs/help_dialog.dart';
import '../widgets/dialogs/hint_dialog.dart';
import 'result_screen.dart';




class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _soundOn = true;
  double _volume = 1.0;

  late GameState _gameState;
  final GameService _gameService = GameService();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startNewGame();
    _playBackgroundSound();
  }

  void _playBackgroundSound() async {
    await player.setReleaseMode(ReleaseMode.loop); // keeps it looping
    await player.play(AssetSource('sounds/background.wav'));
    if (_soundOn) {
      await player.play(AssetSource('sounds/background.wav'));
  }}

  void _startNewGame() {
    setState(() {
      _gameState = GameState(
        secretNumber: _gameService.generateSecretNumber(),
      );
    });
    _controller.clear();
  }

  void _resetGame() {
    _startNewGame();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _focus.requestFocus();
    });
  }

  Future<void> _showHelp() async {
    HapticFeedback.mediumImpact();
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const HelpDialog(),
    );
  }

  Future<void> _useHint() async {
    if (_gameState.hintUsed) return;

    HapticFeedback.mediumImpact();

    final hint = _gameService.generateHint(_gameState.secretNumber);
    final icon = _gameService.getHintIcon(hint);

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => HintDialog(hint: hint, icon: icon),
    );

    setState(() {
      _gameState = _gameState.copyWith(
        hintUsed: true,
        lastFeedback: "💡 Hint revealed!",
      );
    });
  }
  Future<void> _showSettingsDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          title: const Text(
            "🎧 Sound Settings",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Sound:", style: TextStyle(color: Colors.white)),
                  Switch(
                    value: _soundOn,
                    activeColor: Colors.cyanAccent,
                    onChanged: (val) async {
                      setState(() => _soundOn = val);
                      if (_soundOn) {
                        await player.play(AssetSource('sounds/background.wav'));
                        await player.setVolume(_volume);
                      } else {
                        await player.pause();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Volume",
                    style: TextStyle(color: Colors.white),
                  ),
                  Slider(
                    activeColor: Colors.cyanAccent,
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: (_volume * 100).toInt().toString(),
                    onChanged: (value) async {
                      setState(() => _volume = value);
                      await player.setVolume(_volume);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.cyanAccent),
              ),
            ),
          ],
        );
      },
    );
  }


  void _submitGuess() {
    final txt = _controller.text.trim();

    if (txt.isEmpty) {
      setState(() {
        _gameState = _gameState.copyWith(lastFeedback: "⚠️ Enter a number!");
      });
      HapticFeedback.lightImpact();
      return;
    }

    final int? guess = int.tryParse(txt);
    if (guess == null || guess < 0 || guess > 99) {
      setState(() {
        _gameState = _gameState.copyWith(lastFeedback: "⚠️ Must be 0-99");
      });
      HapticFeedback.lightImpact();
      return;
    }

    if (_gameState.guessHistory.contains(guess)) {
      setState(() {
        _gameState = _gameState.copyWith(lastFeedback: "🔄 Already guessed $guess!");
      });
      HapticFeedback.lightImpact();
      _controller.clear();
      return;
    }

    _controller.clear();

    final bool wasCorrect = guess == _gameState.secretNumber;

    setState(() {
      _gameState = _gameService.processGuess(_gameState, guess);
    });

    if (wasCorrect) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _navigateToResult(win: true);
      });
    } else if (_gameState.isGameOver) {
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _navigateToResult(win: false);
      });
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _navigateToResult({required bool win}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          win: win,
          secretNumber: _gameState.secretNumber,
          guessHistory: _gameState.guessHistory,
          livesRemaining: _gameState.lives,
        ),
      ),
    );
  }

  @override
  void dispose() {
    player.stop();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 8),
                        _buildLivesAndHelpRow(),
                        const SizedBox(height: 8),
                        _buildFeedback(),
                        const SizedBox(height: 8),
                        if (_gameState.hasGuesses) _buildGuessHistory(),
                        if (_gameState.hasGuesses) const SizedBox(height: 8),
                        _buildHangmanImage(constraints),
                        const SizedBox(height: 8),
                        _buildInputField(),
                        const SizedBox(height: 8),
                        _buildHintButton(),
                        const SizedBox(height: 8),
                        _buildActionButtons(),
                        const SizedBox(height: 12),
                        _buildFooter(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.blue.withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Hangman",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Number Guessing Challenge",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'settings') _showSettingsDialog();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'settings',
                      child: Text('Sound Settings'),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLivesAndHelpRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _showHelp,
              child: GlassContainer(
                padding: const EdgeInsets.all(6),
                radius: 8,
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.cyanAccent,
                  size: 18,
                ),
              ),
            ),
          ),
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            radius: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Lives",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 6),
                LivesIndicator(
                  currentLives: _gameState.lives,
                  maxLives: GameState.maxLives,
                  compact: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GlassContainer(
        child: Text(
          _gameState.lastFeedback,
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.8,
            fontFamily: 'monospace',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildGuessHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GlassContainer(
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: _gameState.guessHistory.map((g) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  g.toString(),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              )
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildHangmanImage(BoxConstraints constraints) {
    return Flexible(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth * 0.7,
            maxHeight: constraints.maxHeight * 0.35,
          ),
          child: AspectRatio(
            aspectRatio: 0.75,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Image.asset(
                "hangman${GameState.maxLives - _gameState.lives}.png",
                key: ValueKey<int>(_gameState.lives),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        width: double.infinity,
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "0–99",
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onSubmitted: (_) => _submitGuess(),
          ),
        ),
      ),
    );
  }

  Widget _buildHintButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        width: double.infinity,
        child: GlassButton(
          label: _gameState.hintUsed ? "Hint used" : "💡 Get Hint",
          onTap: _useHint,
          enabled: !_gameState.hintUsed,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            child: GlassButton(
              label: "🔄 Reset",
              onTap: _resetGame,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GlassButton(
              label: "✓ Guess",
              onTap: _submitGuess,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.withOpacity(0.08),
            Colors.purple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.copyright,
                  color: Colors.white.withOpacity(0.5),
                  size: 12,
                ),
                const SizedBox(width: 6),
                Text(
                  "2025 COFFEE ☕",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}