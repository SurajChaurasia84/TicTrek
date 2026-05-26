import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'help_support_screen.dart';

class SettingsScreenView extends StatefulWidget {
  final SharedPreferences? prefs;
  final VoidCallback onResetStats;

  const SettingsScreenView({
    super.key,
    required this.prefs,
    required this.onResetStats,
  });

  @override
  State<SettingsScreenView> createState() => _SettingsScreenViewState();
}

class _SettingsScreenViewState extends State<SettingsScreenView> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _showEmotes = true;

  @override
  void initState() {
    super.initState();
    _soundEnabled = widget.prefs?.getBool('soundEnabled') ?? true;
    _vibrationEnabled = widget.prefs?.getBool('vibrationEnabled') ?? true;
    _showEmotes = widget.prefs?.getBool('showEmotes') ?? true;
  }

  void _toggle(String key, bool value) {
    widget.prefs?.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Header
            Center(
              child: Text(
                '⚙️ SETTINGS',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFDD835),
                  letterSpacing: 2,
                  shadows: const [
                    Shadow(color: Colors.black45, offset: Offset(0, 3), blurRadius: 4),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Customize your preferences',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Game Settings
            _buildSectionTitle('GAME'),
            const SizedBox(height: 12),
            _buildToggleTile(
              icon: Icons.volume_up_rounded,
              title: 'Sound Effects',
              subtitle: 'Toggle game sounds',
              value: _soundEnabled,
              onChanged: (v) {
                setState(() => _soundEnabled = v);
                _toggle('soundEnabled', v);
              },
            ),
            const SizedBox(height: 10),
            _buildToggleTile(
              icon: Icons.vibration_rounded,
              title: 'Vibration',
              subtitle: 'Haptic feedback on moves',
              value: _vibrationEnabled,
              onChanged: (v) {
                setState(() => _vibrationEnabled = v);
                _toggle('vibrationEnabled', v);
              },
            ),
            const SizedBox(height: 10),
            _buildToggleTile(
              icon: Icons.emoji_emotions_rounded,
              title: 'Show Emotes',
              subtitle: 'Display floating emotes in game',
              value: _showEmotes,
              onChanged: (v) {
                setState(() => _showEmotes = v);
                _toggle('showEmotes', v);
              },
            ),
            const SizedBox(height: 28),

            // Data & Stats
            _buildSectionTitle('DATA'),
            const SizedBox(height: 12),
            _buildActionTile(
              icon: Icons.refresh_rounded,
              title: 'Reset All Stats',
              subtitle: 'Clear wins, losses, and draws',
              color: Colors.redAccent,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF0A2540),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text(
                      'Reset Stats?',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    content: Text(
                      'This will reset all your game statistics. This cannot be undone.',
                      style: GoogleFonts.outfit(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white54)),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onResetStats();
                          Navigator.pop(ctx);
                        },
                        child: Text('Reset', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'FAQs, rules & support options',
              color: const Color(0xFFFDD835),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              icon: Icons.privacy_tip_rounded,
              title: 'Privacy Policy',
              subtitle: 'Data usage & policy information',
              color: Colors.cyanAccent,
              onTap: () async {
                final Uri url = Uri.parse('https://tictrek.com/privacy-policy');
                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch Privacy Policy URL')),
                  );
                }
              },
            ),
            const SizedBox(height: 28),

            // About
            _buildSectionTitle('ABOUT'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0x0FFFFFFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0x26FFFFFF), width: 1.5),
              ),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Tic',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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
                  const SizedBox(height: 6),
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.outfit(fontSize: 13, color: Colors.white38),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Made with ❤️ by App Verse Game',
                    style: GoogleFonts.outfit(fontSize: 13, color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFDD835), Color(0xFFF5A623)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x26FFFFFF), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0x1AFDD835),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: const Color(0xFFFDD835)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFFDD835),
            activeTrackColor: const Color(0x66FDD835),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0x0FFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x26FFFFFF), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color.withAlpha(150)),
            ],
          ),
        ),
      ),
    );
  }
}
