import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static final AdManager instance = AdManager._internal();
  AdManager._internal();

  AppOpenAd? _appOpenAd;
  bool _isShowingAppOpenAd = false;
  bool _hasShownAppOpenAdThisSession = false; // show only once per app launch

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // ───────────────────────────────────────────────────
  // Ad Unit IDs Configuration (Extracted from AdMob Console)
  // ───────────────────────────────────────────────────
  
  // Real Android App ID: ca-app-pub-2234072069154204~8503949190

  static const bool useTestAds = kDebugMode; // Toggle this to force/disable test ads

  // --- Real Ad Unit IDs (Android) ---
  static const String _realAndroidBanner = 'ca-app-pub-2234072069154204/9022823949';
  static const String _realAndroidInterstitial = 'ca-app-pub-2234072069154204/7907155613';
  static const String _realAndroidRewarded = 'ca-app-pub-2234072069154204/5965415766';
  static const String _realAndroidAppOpen = 'ca-app-pub-2234072069154204/6346661936';

  // --- Real Ad Unit IDs (iOS - Fallback to test IDs; replace with real ones if publishing to iOS) ---
  static const String _realIosBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const String _realIosInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const String _realIosRewarded = 'ca-app-pub-3940256099942544/1712485313';
  static const String _realIosAppOpen = 'ca-app-pub-3940256099942544/5575461077';

  // --- Test Ad Unit IDs (Google Sample IDs) ---
  static const String _testAndroidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testIosBanner = 'ca-app-pub-3940256099942544/2934735716';
  
  static const String _testAndroidInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testIosInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  
  static const String _testAndroidRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testIosRewarded = 'ca-app-pub-3940256099942544/1712485313';
  
  static const String _testAndroidAppOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const String _testIosAppOpen = 'ca-app-pub-3940256099942544/5575461077';

  // Getters to resolve active ad unit ID based on Platform & Environment
  static String get appOpenAdUnitId {
    if (useTestAds) {
      return Platform.isAndroid ? _testAndroidAppOpen : _testIosAppOpen;
    }
    return Platform.isAndroid ? _realAndroidAppOpen : _realIosAppOpen;
  }

  static String get bannerAdUnitId {
    if (useTestAds) {
      return Platform.isAndroid ? _testAndroidBanner : _testIosBanner;
    }
    return Platform.isAndroid ? _realAndroidBanner : _realIosBanner;
  }

  static String get interstitialAdUnitId {
    if (useTestAds) {
      return Platform.isAndroid ? _testAndroidInterstitial : _testIosInterstitial;
    }
    return Platform.isAndroid ? _realAndroidInterstitial : _realIosInterstitial;
  }

  static String get rewardedAdUnitId {
    if (useTestAds) {
      return Platform.isAndroid ? _testAndroidRewarded : _testIosRewarded;
    }
    return Platform.isAndroid ? _realAndroidRewarded : _realIosRewarded;
  }

  // ───────────────────────────────────────────────────
  // SDK Initialization
  // ───────────────────────────────────────────────────
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // ───────────────────────────────────────────────────
  // APP OPEN AD
  // ───────────────────────────────────────────────────
  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          debugPrint('AppOpenAd loaded.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
          _appOpenAd = null;
        },
      ),
    );
  }

  void showAppOpenAdIfAvailable(VoidCallback onDismissed) {
    // Only show once per app session
    if (_hasShownAppOpenAdThisSession) return;
    _hasShownAppOpenAdThisSession = true;

    if (_appOpenAd == null) {
      debugPrint('AppOpenAd not ready — skipping.');
      loadAppOpenAd();
      return;
    }
    if (_isShowingAppOpenAd) return;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        onDismissed();
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AppOpenAd failed to show: $error');
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        onDismissed();
        loadAppOpenAd();
      },
      onAdShowedFullScreenContent: (_) {
        _isShowingAppOpenAd = true;
      },
    );

    _appOpenAd!.show();
  }

  // ───────────────────────────────────────────────────
  // INTERSTITIAL AD
  // ───────────────────────────────────────────────────
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('InterstitialAd loaded.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAdIfAvailable(VoidCallback onFinished) {
    if (_interstitialAd == null) {
      debugPrint('InterstitialAd not ready — calling onFinished.');
      onFinished();
      loadInterstitialAd();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onFinished();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('InterstitialAd failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        onFinished();
        loadInterstitialAd();
      },
    );
    _interstitialAd!.show();
  }

  // ───────────────────────────────────────────────────
  // REWARDED AD
  // ───────────────────────────────────────────────────
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          debugPrint('RewardedAd loaded.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  /// Shows rewarded ad. Calls [onEarnedReward] when user earns the reward.
  /// Calls [onClosed] when the ad is dismissed or fails (regardless of reward).
  void showRewardedAdIfAvailable(
    VoidCallback onEarnedReward,
    VoidCallback onClosed,
  ) {
    if (_rewardedAd == null) {
      debugPrint('RewardedAd not ready — calling onClosed.');
      onClosed();
      loadRewardedAd();
      return;
    }

    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        if (rewardEarned) onEarnedReward();
        onClosed();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedAd failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        onClosed();
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
      },
    );
  }
}
