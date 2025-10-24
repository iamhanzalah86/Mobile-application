import 'package:flutter/material.dart';
import '../widgets/animated_turn_indicator.dart';
import '../widgets/animated_game_cell.dart';
import 'score_screen.dart';

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
  int player1Streak = 0;
  int player2Streak = 0;

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
            player1Streak++;
            player2Streak = 0; // Reset opponent's streak
          } else {
            player2Score++;
            player2Streak++;
            player1Streak = 0; // Reset opponent's streak
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
        // Reset both streaks on draw
        player1Streak = 0;
        player2Streak = 0;
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                winner == 'Draw' ? 'The game is a draw!' : '$winner wins!',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              if (winner != 'Draw') ...[
                SizedBox(height: 10.0),
                Text(
                  'Win Streak: ${winner == widget.player1Name ? player1Streak : player2Streak}',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: winner == widget.player1Name ? Colors.blue : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
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
              child: Text('View Scores'),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToScoreScreen();
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

  void _navigateToScoreScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreScreen(
          player1Name: widget.player1Name,
          player2Name: widget.player2Name,
          player1Score: player1Score,
          player2Score: player2Score,
          player1Streak: player1Streak,
          player2Streak: player2Streak,
        ),
      ),
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
            icon: Icon(Icons.bar_chart),
            onPressed: _navigateToScoreScreen,
            tooltip: 'View Scores',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'Reset Game',
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
                    if (player1Streak > 0)
                      Row(
                        children: <Widget>[
                          Icon(Icons.local_fire_department, color: Colors.orange, size: 16.0),
                          Text(
                            ' $player1Streak',
                            style: TextStyle(fontSize: 14.0, color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                  ],
                ),
                Container(
                  height: 70.0,
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
                    if (player2Streak > 0)
                      Row(
                        children: <Widget>[
                          Icon(Icons.local_fire_department, color: Colors.orange, size: 16.0),
                          Text(
                            ' $player2Streak',
                            style: TextStyle(fontSize: 14.0, color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ],
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
          // Action Buttons
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _navigateToScoreScreen,
                      child: Text('View Scores'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: Text('Main Menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.0),
                ElevatedButton(
                  onPressed: _resetGame,
                  child: Text('Reset Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}