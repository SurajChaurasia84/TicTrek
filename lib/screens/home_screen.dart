import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../services/ad_manager.dart';

class HomeScreenView extends StatefulWidget {
  final Function(GameMode) onStartGame;
  final Difficulty selectedDifficulty;
  final Function(Difficulty) onChangeDifficulty;
  final int playerWins;
  final int opponentWins;
  final int draws;
  final int playerCoins;
  final VoidCallback onResetStats;
  final SharedPreferences? prefs;
  final VoidCallback onCoinsChanged;

  const HomeScreenView({
    super.key,
    required this.onStartGame,
    required this.selectedDifficulty,
    required this.onChangeDifficulty,
    required this.playerWins,
    required this.opponentWins,
    required this.draws,
    required this.playerCoins,
    required this.onResetStats,
    required this.prefs,
    required this.onCoinsChanged,
  });

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  Timer? _adTimer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _checkAdCooldown();

    // Trigger App Open Ad 2 seconds after Home Screen loads
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        AdManager.instance.showAppOpenAdIfAvailable(() {});
      }
    });
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    super.dispose();
  }

  void _checkAdCooldown() {
    final int lastAdClaimTime = widget.prefs?.getInt('lastAdClaimTime') ?? 0;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int elapsedSeconds = (now - lastAdClaimTime) ~/ 1000;
    const int cooldownDuration = 30 * 60; // 30 minutes in seconds

    if (elapsedSeconds < cooldownDuration) {
      setState(() {
        _secondsRemaining = cooldownDuration - elapsedSeconds;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _adTimer?.cancel();
    _adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _adTimer?.cancel();
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _watchAd() {
    if (_secondsRemaining > 0) return;
    VibrationHelper.vibrate(widget.prefs, type: 'selection');

    AdManager.instance.showRewardedAdIfAvailable(
      // onEarnedReward — called only when user fully watches ad
      () {
        if (!mounted) return;
        VibrationHelper.vibrate(widget.prefs, type: 'heavy');
        final int currentCoins = widget.prefs?.getInt('playerCoins') ?? 100;
        widget.prefs?.setInt('playerCoins', currentCoins + 50);
        widget.prefs?.setInt(
            'lastAdClaimTime', DateTime.now().millisecondsSinceEpoch);
        widget.onCoinsChanged();
        setState(() {
          _secondsRemaining = 30 * 60;
        });
        _startTimer();
      },
      // onClosed — called when ad finishes or is dismissed
      () {
        if (!mounted) return;
        // Show reward dialog only if reward was earned (handled above)
        // If closed without reward, do nothing
      },
    );
  }

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

            // Combined Battle Options in a Single Row
            Row(
              children: [
                Expanded(
                  child: _buildBattleModeCard(
                    title: 'BATTLE',
                    subtitle: 'VS AI',
                    icon: Icons.android_rounded,
                    color: const Color(0xFF187BCD),
                    onTap: () {
                      VibrationHelper.vibrate(widget.prefs, type: 'selection');
                      widget.onStartGame(GameMode.vsAi);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBattleModeCard(
                    title: 'PASS & PLAY',
                    subtitle: 'VS FRIEND',
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF2ECC71),
                    onTap: () {
                      VibrationHelper.vibrate(widget.prefs, type: 'selection');
                      widget.onStartGame(GameMode.pvp);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Persistent Watch Ad row
            _buildWatchAdCard(),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFDD835), Color(0xFFF5A623)],
                  ),
                ),
                child: const Text(
                  '👑',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFF176),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x4DFFF176), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💰', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.playerCoins}',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFFEE58),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric('WINS', '${widget.playerWins}', Colors.greenAccent),
              _buildStatMetric('LOSSES', '${widget.opponentWins}', Colors.redAccent),
              _buildStatMetric('DRAWS', '${widget.draws}', Colors.yellowAccent),
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
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildBattleModeCard({
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
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xD8FFFFFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatchAdCard() {
    final bool isTimerActive = _secondsRemaining > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isTimerActive ? null : _watchAd,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            gradient: isTimerActive
                ? const LinearGradient(
                    colors: [Color(0x1EFFFFFF), Color(0x0FFFFFFF)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8E44AD), // Royale styled Purple theme
                      Color(0xFF6C3483),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isTimerActive ? const Color(0x26FFFFFF) : const Color(0xFFFDD835),
              width: 1.5,
            ),
            boxShadow: isTimerActive
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x4D8E44AD),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isTimerActive ? const Color(0x1AFFFFFF) : const Color(0x33FDD835),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  isTimerActive ? '⏱️' : '🎬',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTimerActive
                          ? 'Next Ad Claim available in:'
                          : 'WATCH AD FOR GOLD',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isTimerActive ? Colors.white54 : Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTimerActive
                          ? 'Claimed! Cooldown: ${_formatTime(_secondsRemaining)}'
                          : 'Get 50 Gold Coins every 30 minutes',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isTimerActive ? const Color(0xFFFDD835) : const Color(0xD8FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isTimerActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0x33FDD835),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x80FDD835)),
                  ),
                  child: Text(
                    '+50 💰',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFDD835),
                    ),
                  ),
                ),
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
    final bool isSelected = widget.selectedDifficulty == diff;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          VibrationHelper.vibrate(widget.prefs, type: 'light');
          widget.onChangeDifficulty(diff);
        },
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
                      color: const Color(0x4DF5A623),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
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
