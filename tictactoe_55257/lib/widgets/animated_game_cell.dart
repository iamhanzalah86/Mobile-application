import 'package:flutter/material.dart';
import 'animated_cell_content.dart';

class AnimatedGameCell extends StatefulWidget {
  final String value;
  final VoidCallback onTap;

  AnimatedGameCell({required this.value, required this.onTap});

  @override
  _AnimatedGameCellState createState() => _AnimatedGameCellState();
}

class _AnimatedGameCellState extends State<AnimatedGameCell> {
  double _scale = 1.0;

  void _handleTap() {
    if (widget.value == '') {
      setState(() {
        _scale = 0.9;
      });
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          _scale = 1.0;
        });
      });
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5.0,
              offset: Offset(0.0, 5.0),
            ),
          ],
        ),
        child: Center(
          child: AnimatedCellContent(value: widget.value),
        ),
      ),
    );
  }
}