import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'screens/company_splash.dart';
import 'screens/loading_screen.dart';
import 'screens/main_tab_screen.dart';
import 'screens/game_screen.dart';

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

// ─────────────────────────────────────────────────────────────────────────────
// Shared Enums
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// Game Manager (Screen Navigation Controller)
// ─────────────────────────────────────────────────────────────────────────────
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
    AudioManager.instance.startBgMusic(_prefs);
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
        return MainTabScreen(
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
          prefs: _prefs,
        );
      case ScreenState.gameScreen:
        return GameScreenView(
          mode: _selectedMode,
          difficulty: _selectedDifficulty,
          onBack: _backToHome,
          onGameEnd: _updateStats,
          prefs: _prefs,
        );
    }
  }
}

class AudioManager {
  static final AudioManager instance = AudioManager._internal();
  AudioManager._internal();

  final AudioPlayer _bgPlayer = AudioPlayer();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing AudioManager: $e');
    }
  }

  Future<void> startBgMusic(SharedPreferences? prefs) async {
    await init();
    final bool soundEnabled = prefs?.getBool('soundEnabled') ?? true;
    if (soundEnabled) {
      try {
        if (_bgPlayer.state != PlayerState.playing) {
          await _bgPlayer.play(AssetSource('bg.mp3'));
        }
      } catch (e) {
        debugPrint('Error starting bg music: $e');
      }
    }
  }

  Future<void> stopBgMusic() async {
    try {
      await _bgPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping bg music: $e');
    }
  }

  Future<void> updateBgMusicState(bool soundEnabled) async {
    if (soundEnabled) {
      try {
        if (_bgPlayer.state != PlayerState.playing) {
          await _bgPlayer.play(AssetSource('bg.mp3'));
        }
      } catch (e) {
        debugPrint('Error updating bg music (playing): $e');
      }
    } else {
      await stopBgMusic();
    }
  }
}

class VibrationHelper {
  static void vibrate(SharedPreferences? prefs, {String type = 'light'}) {
    final bool vibrationEnabled = prefs?.getBool('vibrationEnabled') ?? true;
    if (vibrationEnabled) {
      try {
        switch (type) {
          case 'light':
            HapticFeedback.lightImpact();
            break;
          case 'medium':
            HapticFeedback.mediumImpact();
            HapticFeedback.vibrate();
            break;
          case 'heavy':
            HapticFeedback.heavyImpact();
            HapticFeedback.vibrate();
            break;
          case 'selection':
            HapticFeedback.selectionClick();
            break;
          default:
            HapticFeedback.vibrate();
        }
      } catch (e) {
        try {
          HapticFeedback.vibrate();
        } catch (_) {}
      }
    }
  }
}
