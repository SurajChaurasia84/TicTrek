import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x26FDD835),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x66FDD835), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '${(playerWins * 10) + (draws * 2)}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFDD835),
                      ),
                    ),
                  ],
                ),
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
