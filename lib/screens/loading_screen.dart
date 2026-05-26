import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
