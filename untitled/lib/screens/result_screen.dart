import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/background_container.dart';
import '../models/game_state.dart';
import 'game_screen.dart';
import 'menu_screen.dart';

class ResultScreen extends StatelessWidget {
  final bool win;
  final int secretNumber;
  final List<int> guessHistory;
  final int livesRemaining;

  const ResultScreen({
    super.key,
    required this.win,
    required this.secretNumber,
    required this.guessHistory,
    required this.livesRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildResultIcon(),
                    const SizedBox(height: 30),
                    _buildResultTitle(),
                    const SizedBox(height: 20),
                    _buildStats(),
                    const SizedBox(height: 40),
                    _buildButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultIcon() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: win
              ? [Colors.transparent.withOpacity(0.3), Colors.white.withOpacity(0.3)]
              : [Colors.transparent.withOpacity(0.3), Colors.blueGrey.withOpacity(0.3)],
        ),
        boxShadow: [
          BoxShadow(
            color: win ? Colors.transparent.withOpacity(0.4) : Colors.white.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Text(
        win ? "🏆" : "💀",
        style: const TextStyle(fontSize: 80),
      ),
    );
  }

  Widget _buildResultTitle() {
    return Column(
      children: [
        Text(
          win ? "YOU WIN!" : "GAME OVER",
          style: TextStyle(
            color: win ? Colors.transparent : Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontFamily: 'monospace',
            shadows: [
              Shadow(
                color: win ? Colors.transparent : Colors.white,
                blurRadius: 30,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          win ? "Congratulations!" : "Better luck next time!",
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              _buildStatRow("🎯", "Secret Number", secretNumber.toString()),
              const SizedBox(height: 16),
              _buildStatRow("🔢", "Total Guesses", guessHistory.length.toString()),
              const SizedBox(height: 16),
              _buildStatRow("❤️", "Lives Left", "$livesRemaining / ${GameState.maxLives}"),
              if (guessHistory.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                Text(
                  "Your Guesses",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: guessHistory.map((g) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          g.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                          ),
                        ),
                      )
                  ).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        _buildButton(
          context: context,
          icon: "🔄",
          label: "Play Again",
          gradient: [Colors.transparent, Colors.white],
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GameScreen()),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildButton(
          context: context,
          icon: "🏠",
          label: "Main Menu",
          gradient: [Colors.transparent, Colors.white],
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MenuScreen()),
                  (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient.map((c) => c.withOpacity(0.3)).toList(),
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}