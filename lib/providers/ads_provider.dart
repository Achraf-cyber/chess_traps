import 'package:chess_traps/services/ad_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ads_provider.g.dart';

@riverpod
class AdsStateNotifier extends _$AdsStateNotifier {
  @override
  void build() {}

  static String get bannerAdUnitId => AdHelper.bannerAdUnitId;

  static String get rewardedAdUnitId => AdHelper.rewardedInterstitialAdUnitId;

}
