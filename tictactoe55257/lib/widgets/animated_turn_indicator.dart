import 'package:flutter/material.dart';
class AnimatedTurnIndicator extends StatefulWidget {
  final bool isPlayer1Turn;
  final bool gameOver;
  final String player1Name;
  final String player2Name;

  AnimatedTurnIndicator({
    required this.isPlayer1Turn,
    required this.gameOver,
    required this.player1Name,
    required this.player2Name,
  });

  @override
  _AnimatedTurnIndicatorState createState() => _AnimatedTurnIndicatorState();
}

class _AnimatedTurnIndicatorState extends State<AnimatedTurnIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedTurnIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlayer1Turn != widget.isPlayer1Turn) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Text(
              widget.gameOver
                  ? 'Game Over'
                  : '${widget.isPlayer1Turn ? widget.player1Name : widget.player2Name}\'s Turn',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: widget.isPlayer1Turn ? Colors.blue : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }
}