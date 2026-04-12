import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:chess_traps/services/ad_helper.dart';

class InterstitialAdManager {
  factory InterstitialAdManager() => _instance;
  InterstitialAdManager._internal();
  static final InterstitialAdManager _instance =
      InterstitialAdManager._internal();

  InterstitialAd? _interstitialAd;
  int _trapViewsCount = 0;
  static const int _adFrequency = 10;
  DateTime? _lastAdShownAt;
  static const Duration _adCooldown = Duration(minutes: 3);
  bool _isShowingAd = false;

  void loadAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void onTrapViewed() {
    _trapViewsCount++;
    if (_trapViewsCount >= _adFrequency) {
      // Reset count anyway to avoid re-triggering every time if ad not ready
      _trapViewsCount = 0;

      final now = DateTime.now();
      final lastShown = _lastAdShownAt;
      final canShow = lastShown == null ||
          now.difference(lastShown) >= _adCooldown;

      if (canShow && _interstitialAd != null && !_isShowingAd) {
        showAd();
        _lastAdShownAt = now;
      } else {
        if (_interstitialAd == null) loadAd();
      }
    }
  }

  void showAd() {
    final ad = _interstitialAd;
    if (ad == null || _isShowingAd) return;

    _isShowingAd = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _interstitialAd = null;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _interstitialAd = null;
        loadAd();
      },
    );

    ad.show();
    _interstitialAd = null;
  }
}
