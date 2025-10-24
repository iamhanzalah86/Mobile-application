import 'package:flutter/material.dart';

class ScoreScreen extends StatefulWidget {
  final String player1Name;
  final String player2Name;
  final int player1Score;
  final int player2Score;
  final int player1Streak;
  final int player2Streak;

  ScoreScreen({
    required this.player1Name,
    required this.player2Name,
    required this.player1Score,
    required this.player2Score,
    required this.player1Streak,
    required this.player2Streak,
  });

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  double _card1Opacity = 0.0;
  double _card2Opacity = 0.0;
  double _card1Scale = 0.8;
  double _card2Scale = 0.8;

  @override
  void initState() {
    super.initState();
    // Animate cards with delay
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _card1Opacity = 1.0;
        _card1Scale = 1.0;
      });
    });
    Future.delayed(Duration(milliseconds: 400), () {
      setState(() {
        _card2Opacity = 1.0;
        _card2Scale = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score Board'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  // Header
                  Container(
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10.0,
                          offset: Offset(0.0, 5.0),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.emoji_events, color: Colors.amber, size: 30.0),
                        SizedBox(width: 10.0),
                        Text(
                          'Match Statistics',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.0),

                  // Two Column Layout
                  Row(
                    children: <Widget>[
                      // Player 1 Column
                      Expanded(
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 500),
                          opacity: _card1Opacity,
                          child: AnimatedScale(
                            duration: Duration(milliseconds: 500),
                            scale: _card1Scale,
                            curve: Curves.elasticOut,
                            child: PlayerScoreCard(
                              playerName: widget.player1Name,
                              playerSymbol: 'X',
                              score: widget.player1Score,
                              winStreak: widget.player1Streak,
                              color: Colors.blue,
                              backgroundColor: Colors.blue.shade50,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15.0),
                      // Player 2 Column
                      Expanded(
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 500),
                          opacity: _card2Opacity,
                          child: AnimatedScale(
                            duration: Duration(milliseconds: 500),
                            scale: _card2Scale,
                            curve: Curves.elasticOut,
                            child: PlayerScoreCard(
                              playerName: widget.player2Name,
                              playerSymbol: 'O',
                              score: widget.player2Score,
                              winStreak: widget.player2Streak,
                              color: Colors.red,
                              backgroundColor: Colors.red.shade50,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.0),

                  // Winner Section
                  WinnerSection(
                    player1Name: widget.player1Name,
                    player2Name: widget.player2Name,
                    player1Score: widget.player1Score,
                    player2Score: widget.player2Score,
                  ),

                  SizedBox(height: 30.0),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Back to Game',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Player Score Card Widget
class PlayerScoreCard extends StatelessWidget {
  final String playerName;
  final String playerSymbol;
  final int score;
  final int winStreak;
  final Color color;
  final Color backgroundColor;

  PlayerScoreCard({
    required this.playerName,
    required this.playerSymbol,
    required this.score,
    required this.winStreak,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: color, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10.0,
            offset: Offset(0.0, 5.0),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Header with player info
          Container(
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0),
              ),
            ),
            child: Column(
              children: <Widget>[
                Icon(Icons.person, color: Colors.white, size: 40.0),
                SizedBox(height: 5.0),
                Text(
                  playerName,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5.0),
                Text(
                  playerSymbol,
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Score Cards
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                // Total Wins Card
                ScoreDetailCard(
                  icon: Icons.emoji_events,
                  label: 'Total Wins',
                  value: score.toString(),
                  color: color,
                ),
                SizedBox(height: 10.0),
                // Win Streak Card
                ScoreDetailCard(
                  icon: Icons.local_fire_department,
                  label: 'Win Streak',
                  value: winStreak.toString(),
                  color: color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Score Detail Card Widget
class ScoreDetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  ScoreDetailCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5.0,
            offset: Offset(0.0, 3.0),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: color, size: 30.0),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: color,
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

// Winner Section Widget
class WinnerSection extends StatelessWidget {
  final String player1Name;
  final String player2Name;
  final int player1Score;
  final int player2Score;

  WinnerSection({
    required this.player1Name,
    required this.player2Name,
    required this.player1Score,
    required this.player2Score,
  });

  @override
  Widget build(BuildContext context) {
    String leadingPlayer = '';
    Color leadColor = Colors.grey;

    if (player1Score > player2Score) {
      leadingPlayer = '$player1Name is Leading!';
      leadColor = Colors.blue;
    } else if (player2Score > player1Score) {
      leadingPlayer = '$player2Name is Leading!';
      leadColor = Colors.red;
    } else {
      leadingPlayer = 'It\'s a Tie!';
      leadColor = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: leadColor.withOpacity(0.3),
            blurRadius: 10.0,
            offset: Offset(0.0, 5.0),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.military_tech,
            color: leadColor,
            size: 50.0,
          ),
          SizedBox(height: 10.0),
          Text(
            leadingPlayer,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: leadColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.0),
          Text(
            'Score: $player1Score - $player2Score',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}