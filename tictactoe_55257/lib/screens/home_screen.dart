import 'package:flutter/material.dart';
import '../widgets/rotating_icon.dart';
import '../widgets/pulsing_button.dart';
import 'player_setup_screen.dart';
import 'instruction_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _opacity = 0.0;
  double _buttonScale = 0.8;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
        _buttonScale = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe',
        style: TextStyle(color: Colors.black87),
      ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade700],
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 800),
            opacity: _opacity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedContainer(
                  duration: Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      RotatingIcon(),
                      SizedBox(height: 20.0),
                      Text(
                        'Tic Tac Toe',
                        style: TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Classic 3x3 Game',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50.0),
                AnimatedScale(
                  duration: Duration(milliseconds: 600),
                  scale: _buttonScale,
                  curve: Curves.elasticOut,
                  child: PulsingButton(
                    text: 'Start Game',
                    color: Colors.white,
                    textColor: Colors.blue.shade700,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlayerSetupScreen()),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 1000),
                  opacity: _opacity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InstructionsScreen()),
                      );
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.white,),
                    child: Text(
                      'How to Play',
                      style: TextStyle(fontSize: 18.0),
                    ),
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