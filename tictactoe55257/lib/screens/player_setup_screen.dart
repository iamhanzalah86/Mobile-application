import 'package:flutter/material.dart';
import '../screens/game_screen.dart';
class PlayerSetupScreen extends StatefulWidget {
  @override
  _PlayerSetupScreenState createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  String player1Name = 'Player 1';
  String player2Name = 'Player 2';
  double _container1Scale = 0.8;
  double _container2Scale = 0.8;
  double _buttonOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _container1Scale = 1.0;
      });
    });
    Future.delayed(Duration(milliseconds: 400), () {
      setState(() {
        _container2Scale = 1.0;
      });
    });
    Future.delayed(Duration(milliseconds: 600), () {
      setState(() {
        _buttonOpacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Setup'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedScale(
              duration: Duration(milliseconds: 500),
              scale: _container1Scale,
              curve: Curves.elasticOut,
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.person, color: Colors.blue, size: 30.0),
                        SizedBox(width: 10.0),
                        Text(
                          'Player 1 (X)',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Enter Name',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          player1Name = value.isEmpty ? 'Player 1' : value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.0),
            AnimatedScale(
              duration: Duration(milliseconds: 500),
              scale: _container2Scale,
              curve: Curves.elasticOut,
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.person, color: Colors.red, size: 30.0),
                        SizedBox(width: 10.0),
                        Text(
                          'Player 2 (O)',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Enter Name',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          player2Name = value.isEmpty ? 'Player 2' : value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50.0),
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _buttonOpacity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        player1Name: player1Name,
                        player2Name: player2Name,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Start Playing',
                  style: TextStyle(fontSize: 20.0),
                ),
                style: ElevatedButton.styleFrom(


                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,

                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
