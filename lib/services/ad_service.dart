import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();

  factory AdService() {
    return _instance;
  }

  AdService._internal();

  // Real Ad Unit ID as requested
  static const String _rewardedAdUnitId = 'ca-app-pub-3802258742710450/1527112033';

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  void loadRewardedAd({
    required Function(RewardedAd) onAdLoaded,
    required Function(LoadAdError) onAdFailed,
  }) {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('$ad loaded.');
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          onAdFailed(error);
        },
      ),
    );
  }

  void showRewardedAd(RewardedAd ad, Function onAdDismissed) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          debugPrint('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        onAdDismissed();
      },
      onAdImpression: (RewardedAd ad) => debugPrint('$ad impression occurred.'),
    );

    ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      // Reward the user for watching an ad.
      debugPrint('User earned reward: ${rewardItem.amount} ${rewardItem.type}');
    });
  }
}
