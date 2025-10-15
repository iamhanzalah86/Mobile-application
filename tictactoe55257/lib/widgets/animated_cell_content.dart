import 'package:flutter/material.dart';
class AnimatedCellContent extends StatefulWidget {
  final String value;

  AnimatedCellContent({required this.value});

  @override
  _AnimatedCellContentState createState() => _AnimatedCellContentState();
}

class _AnimatedCellContentState extends State<AnimatedCellContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _previousValue = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedCellContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _previousValue && widget.value != '') {
      _previousValue = widget.value;
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
          child: Text(
            widget.value,
            style: TextStyle(
              fontSize: 60.0,
              fontWeight: FontWeight.bold,
              color: widget.value == 'X' ? Colors.blue : Colors.red,
            ),
          ),
        );
      },
    );
  }
}