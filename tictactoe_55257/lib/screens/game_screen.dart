import 'package:flutter/material.dart';
import '../widgets/animated_turn_indicator.dart';
import '../widgets/animated_game_cell.dart' ;
import '../widgets/copyrightfooter.dart';

class GameScreen extends StatefulWidget {
  final String player1Name;
  final String player2Name;

  GameScreen({required this.player1Name, required this.player2Name});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> board = List.filled(9, '');
  bool isPlayer1Turn = true;
  String winner = '';
  bool gameOver = false;
  int player1Score = 0;
  int player2Score = 0;

  void _handleTap(int index) {
    if (board[index] == '' && !gameOver) {
      setState(() {
        board[index] = isPlayer1Turn ? 'X' : 'O';
        _checkWinner();
        isPlayer1Turn = !isPlayer1Turn;
      });
    }
  }

  void _checkWinner() {
    // Winning combinations
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]] != '' &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        setState(() {
          winner = board[pattern[0]] == 'X' ? widget.player1Name : widget.player2Name;
          gameOver = true;
          if (board[pattern[0]] == 'X') {
            player1Score++;
          } else {
            player2Score++;
          }
        });
        _showWinnerDialog();
        return;
      }
    }

    // Check for draw
    if (!board.contains('')) {
      setState(() {
        winner = 'Draw';
        gameOver = true;
      });
      _showWinnerDialog();
    }
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(winner == 'Draw' ? 'Game Draw!' : 'Winner!'),
          content: Text(
            winner == 'Draw' ? 'The game is a draw!' : '$winner wins!',
            style: TextStyle(fontSize: 20.0),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
            ),
            TextButton(
              child: Text('Home'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      isPlayer1Turn = true;
      winner = '';
      gameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Score Board
          Container(
            padding: EdgeInsets.all(20.0),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      widget.player1Name,
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'X',
                      style: TextStyle(fontSize: 24.0, color: Colors.blue),
                    ),
                    Text(
                      'Score: $player1Score',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                Container(
                  height: 50.0,
                  width: 2.0,
                  color: Colors.grey,
                ),
                Column(
                  children: <Widget>[
                    Text(
                      widget.player2Name,
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'O',
                      style: TextStyle(fontSize: 24.0, color: Colors.red),
                    ),
                    Text(
                      'Score: $player2Score',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          // Current Turn Indicator with Animation
          AnimatedTurnIndicator(
            isPlayer1Turn: isPlayer1Turn,
            gameOver: gameOver,
            player1Name: widget.player1Name,
            player2Name: widget.player2Name,
          ),
          SizedBox(height: 20.0),
          // Game Board
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  margin: EdgeInsets.all(20.0),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return AnimatedGameCell(
                        value: board[index],
                        onTap: () => _handleTap(index),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Reset Button
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _resetGame,
                  child: Text('Reset Game'),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  )
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('Main Menu'),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  )
                ),
              ],
            ),
          ),
          const CopyrightFooter(text: "© 2025 Hanzalah Jamal"),
        ],
      ),
    );
  }
}