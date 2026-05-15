import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chess_traps/services/ad_helper.dart';
import 'package:chess_traps/services/remote_config_service.dart';

class RewardedAdManager {
  factory RewardedAdManager() => _instance;
  RewardedAdManager._internal();
  static final RewardedAdManager _instance = RewardedAdManager._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isShowingAd = false;

  void loadAd() {
    if (!RemoteConfigService().adsEnabled) return;
    
    RewardedAd.load(
      adUnitId: AdHelper.rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Rewarded ad loaded');
          _rewardedAd = ad;
          _isAdLoaded = true;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _isShowingAd = true;
            },
            onAdDismissedFullScreenContent: (ad) {
              _isShowingAd = false;
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
              loadAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Failed to show rewarded ad: $error');
              _isShowingAd = false;
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _rewardedAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  bool get isAdAvailable => _isAdLoaded && _rewardedAd != null;

  void showAdIfAvailable({required VoidCallback onRewardEarned, required VoidCallback onFailed}) {
    if (!RemoteConfigService().adsEnabled) {
      // If ads are disabled, instantly give the reward
      onRewardEarned();
      return;
    }
    
    if (_isShowingAd) {
      onFailed();
      return;
    }

    if (!isAdAvailable) {
      loadAd();
      onFailed();
      return;
    }

    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onRewardEarned();
    });
  }
}
