import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Column(
            children: [
              // Custom Header Bar
              _buildHeader(context),
              
              // FAQ Content & Contact Buttons
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FaqItem(
                        question: 'How to play TicTrek?',
                        answer: 'TicTrek is a classic Tic-Tac-Toe game. Take turns placing your mark (X or O) on a 3x3 grid. The first player to align 3 of their marks in a row (horizontally, vertically, or diagonally) wins the game. You can play against the computer or with a friend locally.',
                      ),
                      const FaqItem(
                        question: 'What are the different AI difficulty levels?',
                        answer: '• Easy: The AI makes random moves.\n• Medium: The AI plays optimally (Minimax) 50% of the time, and makes random choices the other 50%.\n• Hard: The AI plays perfectly using Minimax. Beat it if you can!',
                      ),
                      const FaqItem(
                        question: 'How do I unlock items in the Shop?',
                        answer: 'Win matches in different game modes to earn gold coins and trophies! Use them in the Shop tab to unlock premium board themes, custom game markers (X/O skins), and unique emote packs.',
                      ),
                      const FaqItem(
                        question: 'Can I disable sounds and vibration?',
                        answer: 'Yes! Navigate to the Settings tab, where you can toggle Sound Effects, Haptic Vibration, and floating gameplay Emotes on or off based on your preferences.',
                      ),
                      const FaqItem(
                        question: 'How do I reset my stats?',
                        answer: 'Go to Settings -> DATA section, and tap on "Reset All Stats". Please note that this action is permanent and will clear all your wins, losses, and draws.',
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Contact Options
                      Text(
                        'STILL NEED HELP?',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFDD835),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildContactCard(
                        context: context,
                        icon: Icons.email_rounded,
                        title: 'Email Support',
                        subtitle: 'Send us an email at support@tictrek.com',
                        color: Colors.lightBlueAccent,
                        onTap: () async {
                          final Uri emailUri = Uri(
                            scheme: 'mailto',
                            path: 'support@tictrek.com',
                            queryParameters: {
                              'subject': 'TicTrek Support Request',
                            },
                          );
                          if (!await launchUrl(emailUri)) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not open email client')),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          // Styled Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0x0FFFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x26FFFFFF), width: 1.5),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Screen Title
          Text(
            'HELP & SUPPORT',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFFDD835),
              letterSpacing: 1.5,
              shadows: const [
                Shadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: color),
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
              const Icon(Icons.chevron_right_rounded, color: Colors.white30),
            ],
          ),
        ),
      ),
    );
  }
}

class FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const FaqItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? const Color(0xFFFDD835).withAlpha(100) : const Color(0x26FFFFFF),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.question,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _isExpanded ? const Color(0xFFFDD835) : Colors.white,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: _isExpanded ? 0.5 : 0.0,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _isExpanded ? const Color(0xFFFDD835) : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        widget.answer,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
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
