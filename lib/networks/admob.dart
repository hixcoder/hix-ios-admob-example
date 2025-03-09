// admob.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hix_admob_example/utils/constants.dart';

class AdmobAds {
  // Singleton pattern
  static final AdmobAds _instance = AdmobAds._internal();
  factory AdmobAds() => _instance;
  AdmobAds._internal();

  bool _isInitialized = false;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  AppOpenAd? _appOpenAd;
  bool _isShowingAppOpenAd = false;
  DateTime? _appOpenAdLoadTime;

  // Initialize the Google Mobile Ads SDK and load ads
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final status = await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint(
          '==> Admob Initialization complete: ${status.adapterStatuses}');

      await Future.wait([
        _loadAdBanner(),
        _loadAdInter(),
        _loadAdReward(),
        _loadAppOpenAd(),
      ]);
    } catch (e) {
      debugPrint('==> Admob Initialization failed: $e');
      _isInitialized = false;
    }
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
    _isInitialized = false;
  }

  /// Loads a banner ad.
  Future<void> _loadAdBanner() async {
    try {
      await _bannerAd?.dispose();
      _bannerAd = BannerAd(
        adUnitId: Constants.admobBanner,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) => debugPrint('Banner ad loaded successfully'),
          onAdFailedToLoad: (ad, err) {
            debugPrint('BannerAd failed to load: $err');
            ad.dispose();
            _bannerAd = null;
          },
        ),
      );
      await _bannerAd!.load();
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
      _bannerAd = null;
    }
  }

  /// Loads an interstitial ad.
  Future<void> _loadAdInter() async {
    try {
      await InterstitialAd.load(
        adUnitId: Constants.admobInter,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('Interstitial ad loaded successfully');
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (error) {
            debugPrint('InterstitialAd failed to load: $error');
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
      _interstitialAd = null;
    }
  }

  /// Loads a rewarded ad.
  Future<void> _loadAdReward() async {
    try {
      await RewardedAd.load(
        adUnitId: Constants.admobReward,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('Rewarded ad loaded successfully');
            _rewardedAd = ad;
          },
          onAdFailedToLoad: (error) {
            debugPrint('RewardedAd failed to load: $error');
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading rewarded ad: $e');
      _rewardedAd = null;
    }
  }

  Future<void> _loadAppOpenAd() async {
    try {
      await _appOpenAd?.dispose();
      await AppOpenAd.load(
        adUnitId:
            Constants.admobAppOpen, // Make sure to add this in your Constants
        // orientation: AppOpenAd.orientationPortrait,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('App Open ad loaded successfully');
            _appOpenAd = ad;
            _appOpenAdLoadTime = DateTime.now();
          },
          onAdFailedToLoad: (error) {
            debugPrint('App Open ad failed to load: $error');
            _appOpenAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading app open ad: $e');
      _appOpenAd = null;
    }
  }

  /// Shows the app open ad if it's available and not expired
  Future<void> showAppOpenAdIfAvailable() async {
    // if (!_isInitialized) {
    //   debugPrint('Warning: AdMob not initialized');
    //   return;
    // }
    if (!_isInitialized || _appOpenAd == null) {
      debugPrint('Warning: Rewarded ad not ready');
      await _loadAdReward();
      // return;
    }

    if (_isShowingAppOpenAd) {
      debugPrint('Warning: Already showing an app open ad');
      return;
    }

    if (_appOpenAd == null) {
      debugPrint('Warning: App open ad not ready');
      await _loadAppOpenAd();
      return;
    }

    // Check if the loaded ad has expired
    if (_appOpenAdLoadTime != null) {
      final duration = DateTime.now().difference(_appOpenAdLoadTime!);
      if (duration.inHours >= 4) {
        debugPrint('Warning: App open ad expired');
        await _loadAppOpenAd();
        return;
      }
    }

    try {
      _isShowingAppOpenAd = true;
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) =>
            debugPrint('App open ad showed full screen content'),
        onAdDismissedFullScreenContent: (ad) async {
          debugPrint('App open ad dismissed');
          _isShowingAppOpenAd = false;
          await ad.dispose();
          await _loadAppOpenAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) async {
          debugPrint('App open ad failed to show: $error');
          _isShowingAppOpenAd = false;
          await ad.dispose();
          await _loadAppOpenAd();
        },
      );

      await _appOpenAd!.show();
    } catch (e) {
      debugPrint('Error showing app open ad: $e');
      _isShowingAppOpenAd = false;
      await _loadAppOpenAd();
    }
  }

  // Show Rewarded Ad
  Future<void> showRewardedAd(Function rewardUser) async {
    if (!_isInitialized || _rewardedAd == null) {
      debugPrint('Warning: Rewarded ad not ready');
      await _loadAdReward();
      // return;
    }

    try {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) =>
            debugPrint('Rewarded ad showed full screen content'),
        onAdDismissedFullScreenContent: (ad) async {
          debugPrint('Rewarded ad dismissed');
          await ad.dispose();
          await _loadAdReward();
        },
        onAdFailedToShowFullScreenContent: (ad, error) async {
          debugPrint('Rewarded ad failed to show: $error');
          await ad.dispose();
          await _loadAdReward();
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          rewardUser();
        },
      );
      _rewardedAd = null;
    } catch (e) {
      debugPrint('Error showing rewarded ad: $e');
      await _loadAdReward();
    }
  }

  // Show Interstitial Ad
  Future<void> showInterstitialAd() async {
    if (!_isInitialized || _interstitialAd == null) {
      debugPrint('Warning: Interstitial ad not ready');
      await _loadAdInter();
      // return;
    }

    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) =>
            debugPrint('Interstitial ad showed full screen content'),
        onAdDismissedFullScreenContent: (ad) async {
          debugPrint('Interstitial ad dismissed');
          await ad.dispose();
          await _loadAdInter();
        },
        onAdFailedToShowFullScreenContent: (ad, error) async {
          debugPrint('Interstitial ad failed to show: $error');
          await ad.dispose();
          await _loadAdInter();
        },
      );

      await _interstitialAd!.show();
      _interstitialAd = null;
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
      await _loadAdInter();
    }
  }

  // Show Banner Ad Widget
  Widget showBannerAd() {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    if (_bannerAd == null) {
      _loadAdBanner();
      return const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
