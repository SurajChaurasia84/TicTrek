import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'screens/company_splash.dart';
import 'screens/loading_screen.dart';
import 'screens/main_tab_screen.dart';
import 'screens/game_screen.dart';
import 'services/ad_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFF002B4D),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());

  // Initialize AdMob and load ads asynchronously in the background so the
  // Splash Screen renders immediately without any startup delay.
  AdManager.instance.initialize().then((_) {
    AdManager.instance.loadAppOpenAd();
    AdManager.instance.loadInterstitialAd();
    AdManager.instance.loadRewardedAd();
  });
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
  int _playerCoins = 100;
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
      _playerCoins = _prefs?.getInt('playerCoins') ?? 100;
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
    // Re-load coins and stats just in case they were updated in game
    setState(() {
      _playerCoins = _prefs?.getInt('playerCoins') ?? 100;
      _currentScreen = ScreenState.homeScreen;
    });
  }

  void _updateStats(String winner) {
    setState(() {
      if (winner == 'X') {
        _playerWins++;
        _playerCoins += 50;
        _prefs?.setInt('playerWins', _playerWins);
        _prefs?.setInt('playerCoins', _playerCoins);
      } else if (winner == 'O') {
        _aiWins++;
        _prefs?.setInt('aiWins', _aiWins);
      } else if (winner == 'Draw') {
        _draws++;
        _playerCoins += 20;
        _prefs?.setInt('draws', _draws);
        _prefs?.setInt('playerCoins', _playerCoins);
      }

      // Interstitial ad: show after every 3rd completed match
      int matchesCount = (_prefs?.getInt('matchesCount') ?? 0) + 1;
      _prefs?.setInt('matchesCount', matchesCount);
      if (matchesCount % 3 == 0) {
        AdManager.instance.showInterstitialAdIfAvailable(() {
          // No extra action needed — game flow continues normally
        });
      }
    });
  }

  void _resetStats() {
    setState(() {
      _playerWins = 0;
      _aiWins = 0;
      _draws = 0;
      _playerCoins = 100;
      _prefs?.setInt('playerWins', 0);
      _prefs?.setInt('aiWins', 0);
      _prefs?.setInt('draws', 0);
      _prefs?.setInt('playerCoins', 100);
      _prefs?.setString('equippedSkinId', 'classic');
      _prefs?.setStringList('ownedSkinIds', ['classic']);
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
          playerCoins: _playerCoins,
          onResetStats: _resetStats,
          prefs: _prefs,
          onCoinsChanged: () {
            setState(() {
              _playerCoins = _prefs?.getInt('playerCoins') ?? 100;
            });
          },
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
    if (!vibrationEnabled) return;

    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator == true) {
        switch (type) {
          case 'light':
            Vibration.vibrate(duration: 35, amplitude: 120);
            break;
          case 'medium':
            Vibration.vibrate(duration: 80, amplitude: 180);
            break;
          case 'heavy':
            Vibration.vibrate(duration: 180, amplitude: 255);
            break;
          case 'selection':
            Vibration.vibrate(duration: 15, amplitude: 90);
            break;
          default:
            Vibration.vibrate(duration: 100);
        }
      } else {
        // Fallback to standard HapticFeedback if no hardware vibrator detected
        switch (type) {
          case 'light':
            HapticFeedback.lightImpact();
            break;
          case 'medium':
            HapticFeedback.mediumImpact();
            break;
          case 'heavy':
            HapticFeedback.heavyImpact();
            break;
          case 'selection':
            HapticFeedback.selectionClick();
            break;
          default:
            HapticFeedback.vibrate();
        }
      }
    }).catchError((_) {
      // General fallback
      HapticFeedback.vibrate();
    });
  }
}

class SkinItem {
  final String id;
  final String name;
  final String xMarker;
  final String oMarker;
  final String rarity;
  final int price;

  const SkinItem({
    required this.id,
    required this.name,
    required this.xMarker,
    required this.oMarker,
    required this.rarity,
    required this.price,
  });
}

const List<SkinItem> allSkins = [
  SkinItem(id: 'classic', name: 'Classic', xMarker: 'X', oMarker: 'O', rarity: 'Common', price: 0),
  SkinItem(id: 'neon', name: 'Neon', xMarker: 'X', oMarker: 'O', rarity: 'Rare', price: 200),
  SkinItem(id: 'scribble', name: 'Scribble', xMarker: 'X', oMarker: 'O', rarity: 'Rare', price: 300),
  SkinItem(id: 'elemental', name: 'Elemental', xMarker: '🔥', oMarker: '💧', rarity: 'Epic', price: 600),
  SkinItem(id: 'digital', name: 'Digital', xMarker: '👾', oMarker: '🤖', rarity: 'Epic', price: 800),
  SkinItem(id: 'cosmic', name: 'Cosmic', xMarker: '🪐', oMarker: '💫', rarity: 'Epic', price: 1000),
  SkinItem(id: 'royal', name: 'Royal', xMarker: '👑', oMarker: '🛡️', rarity: 'Legendary', price: 1500),
  SkinItem(id: 'stellar', name: 'Stellar', xMarker: '☀️', oMarker: '🌙', rarity: 'Legendary', price: 1800),
  SkinItem(id: 'ninja', name: 'Ninja', xMarker: '🥷', oMarker: '⭐', rarity: 'Legendary', price: 2000),
  SkinItem(id: 'dragon', name: 'Dragon', xMarker: '🐉', oMarker: '🏰', rarity: 'Legendary', price: 2500),
];
