import 'package:flutter/material.dart';
import 'dart:math';

/// Entry point of the application
void main() {
  runApp(const AdventureGame());
}

/// Root widget of the application that sets up the MaterialApp
class AdventureGame extends StatelessWidget {
  const AdventureGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Configure app theme and initial route
    return MaterialApp(
      title: 'Adventure Quest',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Start with splash screen
    );
  }
}

/// Splash screen that displays the game title and animated shield icon
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// State for SplashScreen managing animations
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller with 2-second duration that repeats
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Create rotation animation that tilts the shield left and right
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Create scale animation that makes the shield pulse slightly
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    // Clean up animation controller when widget is disposed
    _controller.dispose();
    super.dispose();
  }

  /// Navigates from splash screen to the main game screen
  void _startGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game title text
            const Text(
              'ADVENTURE QUEST',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 60),
            // Animated shield icon that rotates and scales
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value, // Apply rotation
                  child: Transform.scale(
                    scale: _scaleAnimation.value, // Apply scaling
                    child: child,
                  ),
                );
              },
              child: GestureDetector(
                onTap: _startGame, // Start game when shield is tapped
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Instruction text
            const Text(
              'TAP TO START',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Class that holds all player stats and skill information
class GameState {
  int hp = 100; // Current health points
  int maxHp = 100; // Maximum health points
  int plstr = 8; // Player strength stat
  int plend = 8; // Player endurance stat
  int exp = 0; // Experience points earned
  int unspentSkp = 8; // Unspent skill points for leveling up
  int level = 1; // Player level

  // List of available skill names
  List<String> skills = ['Shield Bash', 'Poison Throw', 'Double Slash', 'Burst Strike'];
  // Corresponding damage values for each skill
  List<int> skillDamage = [18, 12, 24, 30];

  /// Recalculates maxHp based on strength and endurance, then refills HP
  void updateStats() {
    maxHp = 1 + (plstr * 2) + (plend * 4);
    hp = maxHp;
  }
}

/// Class representing an enemy with stats and health
class Enemy {
  String name; // Enemy name
  int hp=1; // Current health points
  int maxHp=1; // Maximum health points
  int str=1; // Strength stat
  int end=1; // Endurance stat
  int exp=1; // Experience points granted on defeat

  /// Constructor that calculates enemy maxHp based on str and end
  Enemy({
    required this.name,
    required this.str,
    required this.end,
    required this.exp,
  }) {
    this.maxHp = 1 + (str * 2) + (end * 4);
    this.hp = maxHp;
  }
}

/// Main game screen that manages menu and battle states
class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

/// State for GameScreen managing game logic and UI
class _GameScreenState extends State<GameScreen> {
  late GameState gameState; // Player's game state
  String currentScreen = 'menu'; // Current screen: 'menu' or 'fight'
  Enemy? currentEnemy; // The enemy currently being fought
  String battleMessage = 'What will you do?'; // Message displayed during battle
  bool isEnemyTurn = false; // Whether it's the enemy's turn to attack
  bool battleEnded = false; // Whether the current battle has ended
  bool playerWon = false; // Whether the player won the battle

  @override
  void initState() {
    super.initState();
    // Initialize game state and calculate initial stats
    gameState = GameState();
    gameState.updateStats();
  }

  /// Starts a battle with the given enemy
  void startBattle(Enemy enemy) {
    setState(() {
      currentEnemy = enemy;
      currentScreen = 'fight'; // Switch to fight screen
      battleMessage = 'A wild ${enemy.name} appears!';
      isEnemyTurn = false;
      battleEnded = false;
      playerWon = false;
    });
  }

  /// Executes player's basic attack action
  void playerAttack() {
    if (isEnemyTurn || battleEnded || currentEnemy == null) return;

    // Calculate damage based on player strength minus enemy endurance
    final damage = max(1, (gameState.plstr * 1.15 - (currentEnemy!.end * 0.1)).toInt());
    currentEnemy!.hp -= damage;

    setState(() {
      battleMessage = 'You attacked for $damage damage!';
      isEnemyTurn = true; // Switch to enemy's turn
    });

    // Wait 2 seconds before enemy counter-attack or battle end
    Future.delayed(const Duration(seconds: 2), () {
      if (currentEnemy!.hp <= 0) {
        endBattle(true); // Player wins
      } else {
        enemyAttack(); // Enemy counter-attacks
      }
    });
  }

  /// Executes player's skill attack
  void playerUseSkill(int skillIndex) {
    if (isEnemyTurn || battleEnded || currentEnemy == null) return;

    // Get skill details and calculate damage
    final skillName = gameState.skills[skillIndex];
    final damage = gameState.skillDamage[skillIndex];
    final actualDamage = max(1, (damage - (currentEnemy!.end * 0.05)).toInt());
    currentEnemy!.hp -= actualDamage;

    setState(() {
      battleMessage = 'You used $skillName!\nDealt $actualDamage damage!';
      isEnemyTurn = true; // Switch to enemy's turn
    });

    // Wait 2 seconds before enemy counter-attack or battle end
    Future.delayed(const Duration(seconds: 2), () {
      if (currentEnemy!.hp <= 0) {
        endBattle(true); // Player wins
      } else {
        enemyAttack(); // Enemy counter-attacks
      }
    });
  }

  /// Executes enemy's attack action
  void enemyAttack() {
    if (currentEnemy == null) return;

    // Calculate damage based on enemy strength minus player endurance
    final damage = max(1, (currentEnemy!.str * 1.15 - (gameState.plend * 0.1)).toInt());
    gameState.hp -= damage;

    setState(() {
      battleMessage = '${currentEnemy!.name} attacked for $damage damage!';
      isEnemyTurn = false; // Switch back to player's turn
    });

    // Wait 2 seconds before returning control to player
    Future.delayed(const Duration(seconds: 2), () {
      if (gameState.hp <= 0) {
        endBattle(false); // Player loses
      } else {
        setState(() {
          battleMessage = 'What will you do?';
        });
      }
    });
  }

  /// Ends the battle and awards experience if player won
  void endBattle(bool playerWon) {
    setState(() {
      battleEnded = true;
      this.playerWon = playerWon;
      if (playerWon) {
        // Award experience and level up
        gameState.exp += currentEnemy!.exp;
        gameState.level += gameState.exp ~/ 10;
        gameState.updateStats();
        battleMessage = 'Victory! Defeated ${currentEnemy!.name}!\nGained ${currentEnemy!.exp} EXP!';
      } else {
        // Restore player health and return to town
        gameState.hp = gameState.maxHp;
        battleMessage = 'You were defeated!\nReturning to town...';
      }
    });
  }

  /// Fully restores player's health
  void heal() {
    gameState.hp = gameState.maxHp;
    setState(() {});
  }

  /// Spends a skill point on either endurance (type=1) or strength (type=2)
  void spendSkillPoint(int type) {
    if (gameState.unspentSkp > 0) {
      setState(() {
        if (type == 1) {
          gameState.plend++; // Increase endurance
        } else {
          gameState.plstr++; // Increase strength
        }
        gameState.unspentSkp--;
        gameState.updateStats(); // Recalculate stats
      });
    }
  }

  /// Starts a random quest based on quest type (1=Forest, 2=Ruins)
  void startQuest(int questType) {
    final random = Random();
    Enemy enemy;

    if (questType == 1) {
      // Forest quest: spawn Goblin or Dire Wolf
      final monType = random.nextInt(3);
      if (monType < 2) {
        enemy = Enemy(name: 'Goblin', str: 8, end: 9, exp: 1);
      } else {
        enemy = Enemy(name: 'Dire Wolf', str: 17, end: 14, exp: 2);
      }
    } else {
      // Ruins quest: spawn Skeleton, Spider, or Skeleton Knight
      final monType = random.nextInt(10);
      if (monType < 5) {
        enemy = Enemy(name: 'Skeleton', str: 12, end: 9, exp: 1);
      } else if (monType < 8) {
        enemy = Enemy(name: 'Spider', str: 25, end: 4, exp: 2);
      } else {
        enemy = Enemy(name: 'Skeleton Knight', str: 15, end: 20, exp: 3);
      }
    }

    startBattle(enemy);
  }

  @override
  Widget build(BuildContext context) {
    // Display either menu or fight screen based on current state
    return Scaffold(
      body: currentScreen == 'menu'
          ? buildMenuScreen()
          : buildFightScreen(),
    );
  }

  /// Builds the main menu screen showing player stats and actions
  Widget buildMenuScreen() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[600],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // City title
                const Text(
                  'CITY OF AAGON',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Player stats container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display player level
                      Text(
                        'Level: ${gameState.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Display current and max HP
                      Text(
                        'HP: ${gameState.hp}/${gameState.maxHp}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Display strength and endurance stats
                      Text(
                        'STR: ${gameState.plstr} | END: ${gameState.plend}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Display experience points
                      Text(
                        'EXP: ${gameState.exp}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Display unspent skill points
                      Text(
                        'Unspent Skill Points: ${gameState.unspentSkp}',
                        style: const TextStyle(
                          color: Colors.lime,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Heal button - restores player to full HP
                MenuButton(
                  label: 'Heal',
                  onPressed: () {
                    heal();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fully healed!')),
                    );
                  },
                  color: Colors.grey[300]!,
                ),
                const SizedBox(height: 12),
                // Forest patrol button - starts forest quest
                MenuButton(
                  label: 'Patrol the Forest',
                  onPressed: () => startQuest(1),
                  color: Colors.grey[300]!,
                ),
                const SizedBox(height: 12),
                // Ruins clearing button - starts ruins quest
                MenuButton(
                  label: 'Clear the Ruins',
                  onPressed: () => startQuest(2),
                  color: Colors.grey[300]!,
                ),
                const SizedBox(height: 12),
                // Level up button - opens skill point spending dialog
                MenuButton(
                  label: 'Level Up',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => StatefulBuilder(
                        builder: (context, setDialogState) => AlertDialog(
                          title: const Text('Spend Skill Points'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Display available skill points
                              Text('Available: ${gameState.unspentSkp}'),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Endurance upgrade button
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    onPressed: () {
                                      spendSkillPoint(1);
                                      setDialogState(() {}); // Update dialog
                                    },
                                    child: const Text('Endurance +1'),
                                  ),
                                  // Strength upgrade button
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      spendSkillPoint(2);
                                      setDialogState(() {}); // Update dialog
                                    },
                                    child: const Text('Strength +1'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            // Close dialog button
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {}); // Update main screen
                              },
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  color: Colors.grey[300]!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the battle screen showing enemy, player, and battle actions
  Widget buildFightScreen() {
    if (currentEnemy == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[800]!, Colors.green[600]!],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Enemy information box at top
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Enemy name
                        Text(
                          currentEnemy!.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Enemy level (calculated from stats)
                        Text(
                          'Lv${(currentEnemy!.str + currentEnemy!.end) ~/ 2}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Enemy HP display
                    Text(
                      'HP: ${currentEnemy!.hp.clamp(0, currentEnemy!.maxHp)}/${currentEnemy!.maxHp}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Enemy HP bar (green/red based on health)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (currentEnemy!.hp.clamp(0, currentEnemy!.maxHp) / currentEnemy!.maxHp).clamp(0.0, 1.0),
                        minHeight: 16,
                        backgroundColor: Colors.grey[700],
                        valueColor: AlwaysStoppedAnimation(
                          currentEnemy!.hp < currentEnemy!.maxHp * 0.3 ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Battle message box in center
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: SizedBox(
                  height: 80,
                  child: Center(
                    // Display current battle message
                    child: Text(
                      battleMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              // Player information box at bottom
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Player label
                        const Text(
                          'PLAYER',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Player level
                        Text(
                          'Lv${gameState.level}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Player HP display
                    Text(
                      'HP: ${gameState.hp.clamp(0, gameState.maxHp)}/${gameState.maxHp}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Player HP bar (green/red based on health)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (gameState.hp.clamp(0, gameState.maxHp) / gameState.maxHp).clamp(0.0, 1.0),
                        minHeight: 16,
                        backgroundColor: Colors.grey[700],
                        valueColor: AlwaysStoppedAnimation(
                          gameState.hp < gameState.maxHp * 0.3 ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Show action buttons during active battle
                    if (!battleEnded && gameState.hp > 0 && currentEnemy!.hp > 0)
                      Row(
                        children: [
                          // Attack button - executes basic attack
                          Expanded(
                            child: FightButton(
                              label: 'ATTACK',
                              onPressed: isEnemyTurn ? null : playerAttack,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Skill button - opens skill selection menu
                          Expanded(
                            child: FightButton(
                              label: 'SKILL',
                              onPressed: isEnemyTurn ? null : () => _showSkillMenu(),
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      )
                    // Show return button after battle ends
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                          ),
                          onPressed: () {
                            // Return to town menu and restore HP
                            setState(() {
                              currentScreen = 'menu';
                              currentEnemy = null;
                              gameState.hp = gameState.maxHp;
                            });
                          },
                          child: const Text(
                            'RETURN TO TOWN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a bottom sheet with all available skills for selection
  void _showSkillMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Skill menu header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'SELECT A SKILL',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Generate a button for each skill
            ...List.generate(
              gameState.skills.length,
                  (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[200],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close skill menu
                      playerUseSkill(index); // Execute selected skill
                    },
                    child: Text(
                      '${gameState.skills[index]} (${gameState.skillDamage[index]} dmg)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Reusable button widget for menu screen actions
class MenuButton extends StatelessWidget {
  final String label; // Button text
  final VoidCallback onPressed; // Action when pressed
  final Color color; // Background color

  const MenuButton({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50), // Full width, 50px height
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

/// Reusable button widget for battle screen actions
class FightButton extends StatelessWidget {
  final String label; // Button text
  final VoidCallback? onPressed; // Action when pressed (nullable for disabled state)
  final Color color; // Background color when enabled

  const FightButton({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed == null ? Colors.grey : color, // Grey when disabled
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}