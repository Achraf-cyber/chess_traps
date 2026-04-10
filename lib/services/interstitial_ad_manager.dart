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
  static const int _adFrequency = 4; // Show ad every 4 trap views

  void loadAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.intersticialAdUnitId,
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
      if (_interstitialAd != null) {
        showAd();
        _trapViewsCount = 0;
      } else {
        // If not loaded, try loading one for next time
        loadAd();
      }
    }
  }

  void showAd() {
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        // Ad showed
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
