import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFF002B4D),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TicTrek',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF002B4D),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const GameManager(),
    );
  }
}

enum ScreenState {
  companySplash,
  loadingScreen,
  homeScreen,
  gameScreen,
}

enum GameMode {
  pvp,
  vsAi,
}

enum Difficulty {
  easy,
  medium,
  hard,
}

class GameManager extends StatefulWidget {
  const GameManager({super.key});

  @override
  State<GameManager> createState() => _GameManagerState();
}

class _GameManagerState extends State<GameManager> {
  ScreenState _currentScreen = ScreenState.companySplash;
  GameMode _selectedMode = GameMode.vsAi;
  Difficulty _selectedDifficulty = Difficulty.medium;

  // Stats
  int _playerWins = 0;
  int _aiWins = 0;
  int _draws = 0;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    // Company Splash display duration
    Timer(const Duration(milliseconds: 2200), () {
      setState(() {
        _currentScreen = ScreenState.loadingScreen;
      });
    });
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _playerWins = _prefs?.getInt('playerWins') ?? 0;
      _aiWins = _prefs?.getInt('aiWins') ?? 0;
      _draws = _prefs?.getInt('draws') ?? 0;
      int diffIndex = _prefs?.getInt('selectedDifficulty') ?? Difficulty.medium.index;
      _selectedDifficulty = Difficulty.values[diffIndex];
    });
  }

  void _onLoadingComplete() {
    setState(() {
      _currentScreen = ScreenState.homeScreen;
    });
  }

  void _startGame(GameMode mode) {
    setState(() {
      _selectedMode = mode;
      _currentScreen = ScreenState.gameScreen;
    });
  }

  void _backToHome() {
    setState(() {
      _currentScreen = ScreenState.homeScreen;
    });
  }

  void _updateStats(String winner) {
    setState(() {
      if (winner == 'X') {
        _playerWins++;
        _prefs?.setInt('playerWins', _playerWins);
      } else if (winner == 'O') {
        _aiWins++;
        _prefs?.setInt('aiWins', _aiWins);
      } else if (winner == 'Draw') {
        _draws++;
        _prefs?.setInt('draws', _draws);
      }
    });
  }

  void _resetStats() {
    setState(() {
      _playerWins = 0;
      _aiWins = 0;
      _draws = 0;
      _prefs?.setInt('playerWins', 0);
      _prefs?.setInt('aiWins', 0);
      _prefs?.setInt('draws', 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentScreen != ScreenState.gameScreen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentScreen == ScreenState.gameScreen) {
          _backToHome();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F4A81),
                Color(0xFF002B4D),
              ],
            ),
          ),
          child: SafeArea(
            child: SizedBox.expand(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: SizedBox.expand(
                  key: ValueKey(_currentScreen),
                  child: _buildCurrentScreen(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case ScreenState.companySplash:
        return const CompanySplashView();
      case ScreenState.loadingScreen:
        return LoadingScreenView(
          onComplete: _onLoadingComplete,
        );
      case ScreenState.homeScreen:
        return HomeScreenView(
          onStartGame: _startGame,
          selectedDifficulty: _selectedDifficulty,
          onChangeDifficulty: (diff) {
            setState(() {
              _selectedDifficulty = diff;
              _prefs?.setInt('selectedDifficulty', diff.index);
            });
          },
          playerWins: _playerWins,
          opponentWins: _aiWins,
          draws: _draws,
          onResetStats: _resetStats,
        );
      case ScreenState.gameScreen:
        return GameScreenView(
          mode: _selectedMode,
          difficulty: _selectedDifficulty,
          onBack: _backToHome,
          onGameEnd: _updateStats,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Company Splash Screen View
// ─────────────────────────────────────────────────────────────────────────────
class CompanySplashView extends StatefulWidget {
  const CompanySplashView({super.key});

  @override
  State<CompanySplashView> createState() => _CompanySplashViewState();
}

class _CompanySplashViewState extends State<CompanySplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'App verse game',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: const Color(0x66FDD835),
                      blurRadius: 15,
                    ),
                    const Shadow(
                      color: Colors.black54,
                      offset: Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 140,
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFDD835),
                      Color(0xFFF5A623),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x99FDD835),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Loading Screen View
// ─────────────────────────────────────────────────────────────────────────────
class LoadingScreenView extends StatefulWidget {
  final VoidCallback onComplete;
  const LoadingScreenView({super.key, required this.onComplete});

  @override
  State<LoadingScreenView> createState() => _LoadingScreenViewState();
}

class _LoadingScreenViewState extends State<LoadingScreenView> {
  double _progressValue = 0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    // Simulate loading progress bar
    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_progressValue < 100) {
          _progressValue += 1;
        } else {
          _progressTimer?.cancel();
          Future.delayed(const Duration(milliseconds: 400), widget.onComplete);
        }
      });
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Tic',
                style: GoogleFonts.outfit(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: const [
                    Shadow(color: Colors.black45, offset: Offset(0, 3), blurRadius: 4),
                  ],
                ),
                children: [
                  TextSpan(
                    text: 'Trek',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFDD835),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Loading bouncing emojis grid
            SizedBox(
              height: 120,
              width: 260,
              child: GridView.count(
                crossAxisCount: 4,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  BouncingEmoji(emoji: '👾', delayMs: 0),
                  BouncingEmoji(emoji: '🤖', delayMs: 100),
                  BouncingEmoji(emoji: '👑', delayMs: 200),
                  BouncingEmoji(emoji: '🛡️', delayMs: 300),
                  BouncingEmoji(emoji: '☀️', delayMs: 400),
                  BouncingEmoji(emoji: '🌙', delayMs: 500),
                  BouncingEmoji(emoji: '🥷', delayMs: 600),
                  BouncingEmoji(emoji: '⭐', delayMs: 700),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${_progressValue.toInt()}%',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFDD835),
                shadows: const [
                  Shadow(color: Colors.black45, offset: Offset(0, 2), blurRadius: 4),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // Progress Bar Container
            Container(
              width: double.infinity,
              height: 18,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFDD835),
                  width: 2.0,
                ),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressValue / 100.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFDD835),
                        Color(0xFFFBC02D),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BouncingEmoji extends StatefulWidget {
  final String emoji;
  final int delayMs;
  const BouncingEmoji({super.key, required this.emoji, required this.delayMs});

  @override
  State<BouncingEmoji> createState() => _BouncingEmojiState();
}

class _BouncingEmojiState extends State<BouncingEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.0, end: -18.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Center(
            child: Text(
              widget.emoji,
              style: const TextStyle(fontSize: 34),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Home Screen View
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreenView extends StatelessWidget {
  final Function(GameMode) onStartGame;
  final Difficulty selectedDifficulty;
  final Function(Difficulty) onChangeDifficulty;
  final int playerWins;
  final int opponentWins;
  final int draws;
  final VoidCallback onResetStats;

  const HomeScreenView({
    super.key,
    required this.onStartGame,
    required this.selectedDifficulty,
    required this.onChangeDifficulty,
    required this.playerWins,
    required this.opponentWins,
    required this.draws,
    required this.onResetStats,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // App Title header
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Tic',
                style: GoogleFonts.outfit(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: const [
                    Shadow(color: Colors.black45, offset: Offset(0, 3), blurRadius: 4),
                  ],
                ),
                children: [
                  TextSpan(
                    text: 'Trek',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFDD835),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Premium Player Status Card
            _buildPlayerStatsCard(),
            const SizedBox(height: 25),
            // Main Battle Options
            _buildBattleModeButton(
              title: 'PLAYER BATTLE',
              subtitle: 'VS AI OPPONENT',
              icon: Icons.android_rounded,
              color: const Color(0xFF187BCD),
              onTap: () => onStartGame(GameMode.vsAi),
            ),
            const SizedBox(height: 15),
            _buildBattleModeButton(
              title: 'PASS & PLAY',
              subtitle: 'VS LOCAL FRIEND',
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF2ECC71),
              onTap: () => onStartGame(GameMode.pvp),
            ),
            const SizedBox(height: 25),
            // Difficulty Section Header
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'SELECT AI DIFFICULTY',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFDD835),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Difficulty Selector Grid
            _buildDifficultyGrid(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0x26FFFFFF),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFDD835), Color(0xFFF5A623)],
                  ),
                ),
                child: const Text(
                  '👑',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trek Master',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Arena Rank 1',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white54),
                tooltip: 'Reset Stats',
                onPressed: onResetStats,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric('WINS', '$playerWins', Colors.greenAccent),
              _buildStatMetric('LOSSES', '$opponentWins', Colors.redAccent),
              _buildStatMetric('DRAWS', '$draws', Colors.yellowAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildBattleModeButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withAlpha((0.7 * 255).round()),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0x7FFDD835),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha((0.35 * 255).round()),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 45, color: Colors.white),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xD8FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyGrid() {
    return Row(
      children: [
        _buildDifficultyCard(Difficulty.easy, 'EASY', '👾'),
        const SizedBox(width: 10),
        _buildDifficultyCard(Difficulty.medium, 'MED', '🤖'),
        const SizedBox(width: 10),
        _buildDifficultyCard(Difficulty.hard, 'HARD', '🛡️'),
      ],
    );
  }

  Widget _buildDifficultyCard(Difficulty diff, String label, String icon) {
    final bool isSelected = selectedDifficulty == diff;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChangeDifficulty(diff),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFDD835) : const Color(0x0FFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFF5A623) : const Color(0x26FFFFFF),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0x66FDD835),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? const Color(0xFF4A2C0F) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Game Screen View (Board, Scoreboard, Emotes)
// ─────────────────────────────────────────────────────────────────────────────
class GameScreenView extends StatefulWidget {
  final GameMode mode;
  final Difficulty difficulty;
  final VoidCallback onBack;
  final Function(String) onGameEnd;

  const GameScreenView({
    super.key,
    required this.mode,
    required this.difficulty,
    required this.onBack,
    required this.onGameEnd,
  });

  @override
  State<GameScreenView> createState() => _GameScreenViewState();
}

class _GameScreenViewState extends State<GameScreenView> {
  late List<String> _board;
  late String _currentPlayer;
  late bool _gameOver;
  String _winner = '';
  List<int> _winningLine = [];
  bool _aiThinking = false;

  // Active Emotes for Floating animation
  final List<ActiveEmote> _activeEmotes = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _board = List.generate(9, (_) => '');
      _currentPlayer = 'X'; // X is Player, O is Opponent (AI / Friend)
      _gameOver = false;
      _winner = '';
      _winningLine = [];
      _aiThinking = false;
    });
  }

  void _handleCellClick(int index) {
    if (_board[index] != '' || _gameOver || _aiThinking) return;

    setState(() {
      _board[index] = _currentPlayer;
      _checkWinner();

      if (!_gameOver) {
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
        if (widget.mode == GameMode.vsAi && _currentPlayer == 'O') {
          _aiThinking = true;
          _runAiMove();
        }
      }
    });
  }

  void _runAiMove() {
    // Artificial slight delay to feel like the AI is thinking
    int delay = 500 + _random.nextInt(600);
    Timer(Duration(milliseconds: delay), () {
      if (!mounted || _gameOver) return;

      int bestMove = _calculateAiMove();
      if (bestMove != -1) {
        setState(() {
          _board[bestMove] = 'O';
          _checkWinner();
          _aiThinking = false;
          if (!_gameOver) {
            _currentPlayer = 'X';
          }
        });
      }
    });
  }

  int _calculateAiMove() {
    // All difficulties use Minimax (perfect play)
    return _getMinimaxMove();
  }

  int _getRandomMove() {
    List<int> available = [];
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') available.add(i);
    }
    if (available.isEmpty) return -1;
    return available[_random.nextInt(available.length)];
  }

  int _getMinimaxMove() {
    int bestScore = -1000;
    int bestMove = -1;

    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        _board[i] = 'O';
        int score = _minimax(0, false);
        _board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    return bestMove;
  }

  int _minimax(int depth, bool isMax) {
    String scoreWinner = _evaluateBoard();
    if (scoreWinner == 'O') return 10 - depth;
    if (scoreWinner == 'X') return depth - 10;
    if (!_board.contains('')) return 0;

    if (isMax) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (_board[i] == '') {
          _board[i] = 'O';
          int score = _minimax(depth + 1, false);
          _board[i] = '';
          bestScore = max(bestScore, score);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (_board[i] == '') {
          _board[i] = 'X';
          int score = _minimax(depth + 1, true);
          _board[i] = '';
          bestScore = min(bestScore, score);
        }
      }
      return bestScore;
    }
  }

  String _evaluateBoard() {
    List<List<int>> lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ];

    for (var line in lines) {
      if (_board[line[0]] != '' &&
          _board[line[0]] == _board[line[1]] &&
          _board[line[0]] == _board[line[2]]) {
        return _board[line[0]];
      }
    }
    return '';
  }

  void _checkWinner() {
    List<List<int>> lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ];

    for (var line in lines) {
      if (_board[line[0]] != '' &&
          _board[line[0]] == _board[line[1]] &&
          _board[line[0]] == _board[line[2]]) {
        _winner = _board[line[0]];
        _winningLine = line;
        _gameOver = true;
        widget.onGameEnd(_winner);
        return;
      }
    }

    if (!_board.contains('')) {
      _winner = 'Draw';
      _gameOver = true;
      widget.onGameEnd('Draw');
    }
  }

  void _triggerEmote(String emote, bool isPlayer) {
    final emoteId = DateTime.now().millisecondsSinceEpoch;
    final xPosition = isPlayer ? 0.25 : 0.75;
    setState(() {
      _activeEmotes.add(
        ActiveEmote(
          id: emoteId,
          emoji: emote,
          xRatio: xPosition,
        ),
      );
    });

    // Cleanup emote after animation duration
    Timer(const Duration(milliseconds: 2000), () {
      setState(() {
        _activeEmotes.removeWhere((item) => item.id == emoteId);
      });
    });

    // If PvP mode, occasionally make the other player send an auto-emote reaction
    if (widget.mode == GameMode.vsAi && isPlayer && _random.nextDouble() > 0.4) {
      Timer(const Duration(milliseconds: 800), () {
        if (!mounted || _gameOver) return;
        List<String> aiEmotes = ['😠', '😭', '👑', '👍', '😂'];
        _triggerEmote(aiEmotes[_random.nextInt(aiEmotes.length)], false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Emotes float overlays
        ..._activeEmotes.map((e) => FloatingEmoteWidget(key: ValueKey(e.id), emote: e)),

        // Main game content layout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // Header Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
                    onPressed: widget.onBack,
                  ),
                  Text(
                    widget.mode == GameMode.vsAi
                        ? 'BATTLE vs AI (${widget.difficulty.name.toUpperCase()})'
                        : 'LOCAL PvP MATCH',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFDD835),
                      letterSpacing: 1.0,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                    onPressed: _resetGame,
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Game turn indicator / status banner
              _buildGameStatusWidget(),
              const SizedBox(height: 25),

              // Interactive 3x3 Game Board
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0x0AFFFFFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0x1EFFFFFF),
                          width: 1.5,
                        ),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 9,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          final isWinningCell = _winningLine.contains(index);
                          return _buildCell(index, isWinningCell);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Interactive Emotes triggers Panel
              _buildEmoteTriggers(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameStatusWidget() {
    String message = '';
    Color statusColor = Colors.white;

    if (_gameOver) {
      if (_winner == 'Draw') {
        message = "IT'S A DRAW!";
        statusColor = const Color(0xFFFDD835);
      } else {
        message = "PLAYER $_winner WINS!";
        statusColor = _winner == 'X' ? Colors.greenAccent : const Color(0xFFE74C3C);
      }
    } else {
      if (_currentPlayer == 'X') {
        message = "YOUR TURN (X)";
        statusColor = Colors.greenAccent;
      } else {
        message = widget.mode == GameMode.vsAi ? "AI THINKING..." : "PLAYER O TURN";
        statusColor = const Color(0xFFFDD835);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0x1EFFFFFF),
        ),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            message,
            key: ValueKey(message),
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: statusColor,
              letterSpacing: 1.2,
              shadows: const [
                Shadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int index, bool isWinningCell) {
    final String val = _board[index];
    Color markerColor = Colors.white;
    if (val == 'X') {
      markerColor = Colors.white;
    } else if (val == 'O') {
      markerColor = const Color(0xFFFDD835);
    }

    return GestureDetector(
      onTap: () => _handleCellClick(index),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isWinningCell
                ? [
                    const Color(0xFFFDD835),
                    const Color(0xFFD35400),
                  ]
                : [
                    const Color(0xD8187BCD),
                    const Color(0xD80F5AA1),
                  ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isWinningCell
                ? Colors.white
                : const Color(0x66FDD835),
            width: isWinningCell ? 2.5 : 1.5,
          ),
          boxShadow: isWinningCell
              ? [
                  BoxShadow(
                    color: const Color(0x7FFFDB35),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedScale(
            scale: val != '' ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            child: Text(
              val,
              style: GoogleFonts.outfit(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: markerColor,
                shadows: [
                  Shadow(
                    color: const Color(0x99000000),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmoteTriggers() {
    final List<String> emotes = ['👑', '🔥', '😂', '😭', '👍'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1EFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mood_rounded, size: 18, color: Color(0xFFFDD835)),
              const SizedBox(width: 8),
              Text(
                'SEND EMOTE',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white70,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: emotes.map((emote) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _triggerEmote(emote, true),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0x0DFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      emote,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Emote representation
class ActiveEmote {
  final int id;
  final String emoji;
  final double xRatio; // Screen fraction horizontally

  const ActiveEmote({
    required this.id,
    required this.emoji,
    required this.xRatio,
  });
}

class FloatingEmoteWidget extends StatefulWidget {
  final ActiveEmote emote;
  const FloatingEmoteWidget({super.key, required this.emote});

  @override
  State<FloatingEmoteWidget> createState() => _FloatingEmoteWidgetState();
}

class _FloatingEmoteWidgetState extends State<FloatingEmoteWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translateY;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _translateY = Tween<double>(begin: 0.0, end: -350.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_controller);

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.4, end: 1.2), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 65),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double leftOffset = widget.emote.xRatio * size.width - 35;

    return Positioned(
      bottom: 120, // Float starts above emote toolbar
      left: leftOffset,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _translateY.value),
            child: Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
                  child: Text(
                    widget.emote.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
