import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../data/my_strings.dart';

class AdMob {

  static const String testDeviceID = '29AF339CAD87B070245DAD9AB32CF981';

  static void init(){
    WidgetsFlutterBinding.ensureInitialized();
    MobileAds.instance.initialize();
  }

  static String? get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return MyStrings.ANDROID_AD_UNIT_INTERSTITIAL;
    } else if (Platform.isIOS) {
      return MyStrings.IOS_AD_UNIT_INTERSTITIAL;
    }
    return null;
  }

  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return MyStrings.ANDROID_AD_UNIT_BANNER;
    } else if (Platform.isIOS) {
      return MyStrings.IOS_AD_UNIT_BANNER;
    }
    return null;
  }

  static createInterstitialAd(AdListener adListener) {
    InterstitialAd.load(
        adUnitId: interstitialAdUnitId!, request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            adListener.onIntersAdLoaded!(ad);
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                adListener.onAdClosed!();
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
            adListener.onAdFailedToLoad!(error);
          },
        )
    );
  }

  static BannerAd createBannerAd(AdListener adListener) {
    return BannerAd(
      adUnitId: bannerAdUnitId!, size: AdSize.banner, request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          adListener.onBannerAdLoaded!();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Ad failed to load: $error');
          ad.dispose();
          adListener.onAdFailedToLoad!(error);
        },
        onAdClosed: (Ad ad) {
          adListener.onAdClosed!();
        },
      ),
    );

  }

}

typedef AdIntersLoaded = void Function(InterstitialAd ad);
typedef AdBannerLoaded = void Function();
typedef AdFailedToLoad = void Function(LoadAdError error);

class AdListener {

  final AdIntersLoaded? onIntersAdLoaded;
  final AdBannerLoaded? onBannerAdLoaded;
  final Function? onAdFailedToLoad;
  final Function? onAdClosed;

  const AdListener({
    this.onIntersAdLoaded,
    this.onBannerAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClosed
  });
}
