import 'package:flutter/material.dart';
import '../widgets/animated_instruction_header.dart';

class InstructionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('How to Play'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AnimatedInstructionHeader(),
              SizedBox(height: 20.0),
              Text(
                '1. The game is played on a 3x3 grid',
                style: TextStyle(fontSize: 16.0),
              ),
              Divider(),
              Text(
                '2. Players take turns placing X or O',
                style: TextStyle(fontSize: 16.0),
              ),
              Divider(),
              Text(
                '3. First player to get 3 marks in a row wins',
                style: TextStyle(fontSize: 16.0),
              ),
              Divider(),
              Text(
                '4. Rows can be horizontal, vertical, or diagonal',
                style: TextStyle(fontSize: 16.0),
              ),
              Divider(),
              Text(
                '5. If all 9 squares are filled with no winner, the game is a draw',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 30.0),
              Center(
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text('X', style: TextStyle(fontSize: 40.0, color: Colors.blue)),
                          Text('O', style: TextStyle(fontSize: 40.0, color: Colors.red)),
                          Text('X', style: TextStyle(fontSize: 40.0, color: Colors.blue)),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text('O', style: TextStyle(fontSize: 40.0, color: Colors.red)),
                          Text('X', style: TextStyle(fontSize: 40.0, color: Colors.blue)),
                          Text('O', style: TextStyle(fontSize: 40.0, color: Colors.red)),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text('X', style: TextStyle(fontSize: 40.0, color: Colors.blue)),
                          Text('O', style: TextStyle(fontSize: 40.0, color: Colors.red)),
                          Text('X', style: TextStyle(fontSize: 40.0, color: Colors.blue)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Got It!'),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}