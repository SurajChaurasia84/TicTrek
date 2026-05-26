import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

import 'package:shared_preferences/shared_preferences.dart';

class GameScreenView extends StatefulWidget {
  final GameMode mode;
  final Difficulty difficulty;
  final VoidCallback onBack;
  final Function(String) onGameEnd;
  final SharedPreferences? prefs;

  const GameScreenView({
    super.key,
    required this.mode,
    required this.difficulty,
    required this.onBack,
    required this.onGameEnd,
    required this.prefs,
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
    VibrationHelper.vibrate(widget.prefs, type: 'light');

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
        VibrationHelper.vibrate(widget.prefs, type: 'heavy');
        widget.onGameEnd(_winner);
        return;
      }
    }

    if (!_board.contains('')) {
      _winner = 'Draw';
      _gameOver = true;
      VibrationHelper.vibrate(widget.prefs, type: 'heavy');
      widget.onGameEnd('Draw');
    }
  }

  void _triggerEmote(String emote, bool isPlayer) {
    final emoteId = DateTime.now().millisecondsSinceEpoch;
    final xPosition = isPlayer ? 0.25 : 0.75;
    if (isPlayer) {
      VibrationHelper.vibrate(widget.prefs, type: 'medium');
    }
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
    final bool showEmotes = widget.prefs?.getBool('showEmotes') ?? true;
    return Stack(
      children: [
        // Emotes float overlays
        if (showEmotes)
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
              if (showEmotes) ...[
                _buildEmoteTriggers(),
                const SizedBox(height: 10),
              ],
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
