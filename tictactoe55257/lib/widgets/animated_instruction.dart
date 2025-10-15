import 'package:flutter/material.dart';
class AnimatedInstruction extends StatefulWidget {
  @override
  _AnimatedInstructionState createState() => _AnimatedInstructionState();
}

class _AnimatedInstructionState extends State<AnimatedInstruction> {
  double _width = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _width = double.infinity;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeOut,
      width: _width,
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.info, color: Colors.blue, size: 30.0),
          SizedBox(width: 10.0),
          Text(
            'Game Rules',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}