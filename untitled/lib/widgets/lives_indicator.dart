import 'dart:ui';
import 'package:flutter/material.dart';

class LivesIndicator extends StatelessWidget {
  final int currentLives;
  final int maxLives;
  final bool compact;

  const LivesIndicator({
    super.key,
    required this.currentLives,
    required this.maxLives,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        maxLives,
            (i) => Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 1.5 : 3),
          child: _buildHeart(i < currentLives, compact),
        ),
      ),
    );
  }

  Widget _buildHeart(bool alive, bool compact) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 6 : 10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: compact ? 6 : 8, sigmaY: compact ? 6 : 8),
        child: Container(
          padding: EdgeInsets.all(compact ? 3 : 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.01),
            borderRadius: BorderRadius.circular(compact ? 6 : 10),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Icon(
            Icons.favorite,
            color: alive ? Colors.redAccent : Colors.redAccent.withOpacity(0.22),
            size: compact ? 14 : 20,
          ),
        ),
      ),
    );
  }
}