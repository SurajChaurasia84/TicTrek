import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'home_screen.dart';
import 'shop_screen.dart';
import 'settings_screen.dart';

class MainTabScreen extends StatefulWidget {
  final Function(GameMode) onStartGame;
  final Difficulty selectedDifficulty;
  final Function(Difficulty) onChangeDifficulty;
  final int playerWins;
  final int opponentWins;
  final int draws;
  final VoidCallback onResetStats;
  final SharedPreferences? prefs;

  const MainTabScreen({
    super.key,
    required this.onStartGame,
    required this.selectedDifficulty,
    required this.onChangeDifficulty,
    required this.playerWins,
    required this.opponentWins,
    required this.draws,
    required this.onResetStats,
    required this.prefs,
  });

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab content area
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildTabContent(),
          ),
        ),
        // Premium Bottom Navigation Bar
        _buildBottomNavBar(),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreenView(
          key: const ValueKey('home_tab'),
          onStartGame: widget.onStartGame,
          selectedDifficulty: widget.selectedDifficulty,
          onChangeDifficulty: widget.onChangeDifficulty,
          playerWins: widget.playerWins,
          opponentWins: widget.opponentWins,
          draws: widget.draws,
          onResetStats: widget.onResetStats,
        );
      case 1:
        return const ShopScreenView(key: ValueKey('shop_tab'));
      case 2:
        return SettingsScreenView(
          key: const ValueKey('settings_tab'),
          prefs: widget.prefs,
          onResetStats: widget.onResetStats,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF001F3A),
        border: Border(
          top: BorderSide(color: Color(0x33FDD835), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.storefront_rounded, 'Shop'),
          _buildNavItem(2, Icons.settings_rounded, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0x33FDD835), Color(0x1AFDD835)],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? const Color(0xFFFDD835) : Colors.white38,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? const Color(0xFFFDD835) : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
