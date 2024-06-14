import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

import '../ad_config.dart';
import '../main.dart';

class AutoclickerScreen extends StatefulWidget {
  const AutoclickerScreen({super.key});

  @override
  AutoclickerScreenState createState() => AutoclickerScreenState();
}

class AutoclickerScreenState extends State<AutoclickerScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _loadAd();
      _adLoader = _createRewardedAdLoader();
      await _loadRewardedAd();
    });
  }

  // ! ads start ----------------------------------------------------------------

  late BannerAd banner1;
  late BannerAd banner2;
  var isBannerAlreadyCreated = false;

  late final Future<RewardedAdLoader> _adLoader;
  RewardedAd? _ad;

  BannerAdSize _getBannerAdSize() {
    final width = MediaQuery.of(context).size.width.round();
    return BannerAdSize.sticky(width: width);
  }

  BannerAd _createBanner1() {
    return BannerAd(
      adUnitId: adConfig.packBottomBanner, // "demo-banner-yandex",
      adSize: _getBannerAdSize(),
      adRequest: const AdRequest(),
      onAdLoaded: () {
        print("YandexMobileads banner 1 onAdLoaded");
        if (!mounted) {
          banner1.destroy();
          return;
        }
      },
    );
  }

  BannerAd _createBanner2() {
    return BannerAd(
      adUnitId: adConfig.albumBottomBanner, // "demo-banner-yandex",
      adSize: _getBannerAdSize(),
      adRequest: const AdRequest(),
      onAdLoaded: () {
        print("YandexMobileads banner 2 onAdLoaded");
        if (!mounted) {
          banner1.destroy();
          return;
        }
      },
    );
  }

  void _loadAd() async {
    banner1 = _createBanner1();
    banner2 = _createBanner2();
    setState(() {
      isBannerAlreadyCreated = true;
    });
  }

  Future<RewardedAdLoader> _createRewardedAdLoader() {
    return RewardedAdLoader.create(
      onAdLoaded: (rewardedAd) {
        _ad = rewardedAd;
      },
    );
  }

  Future<void> _loadRewardedAd() async {
    final adLoader = await _adLoader;
    await adLoader.loadAd(
      adRequestConfiguration: AdRequestConfiguration(
        adUnitId: adConfig.openPackAd, // 'demo-rewarded-yandex',
      ),
    );
    final randomSeconds = Random().nextInt(5);
    print("YandexMobileads randomSeconds $randomSeconds");
    await Future.delayed(Duration(seconds: randomSeconds));
    await _showRewardedAd();
  }

  Future<void> _showRewardedAd() async {
    _ad?.setAdEventListener(
      eventListener: RewardedAdEventListener(
        onAdFailedToShow: (error) {
          _ad?.destroy();
          _ad = null;
          _loadRewardedAd();
        },
        onAdDismissed: () {
          _ad?.destroy();
          _ad = null;
          _loadRewardedAd();
        },
        onAdImpression: (impressionData) {
          print("YandexMobileads onAdImpression");
        },
        onAdShown: () {
          print("YandexMobileads onAdShown");
        },
        onRewarded: (reward) {
          print("YandexMobileads onRewarded");
          final randomSeconds = Random().nextInt(5);
          print("YandexMobileads randomSeconds $randomSeconds");
          Future.delayed(Duration(seconds: randomSeconds)).whenComplete(() {
            RestartWidget.restartApp(context);
          });
        },
      ),
    );

    await _ad?.show();
    final reward = await _ad?.waitForDismiss();
    if (reward != null) {
      // TODO do something
    }
  }

  // ! ads end ---------------------------------------------------------------

  @override
  void dispose() {
    _ad?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 35, 43, 56),
      body: Stack(
        children: [
          if (isBannerAlreadyCreated)
            Positioned(
              top: 40,
              right: 0,
              left: 0,
              child: AdWidget(bannerAd: banner2),
            ),
          if (isBannerAlreadyCreated)
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: AdWidget(bannerAd: banner1),
            ),
        ],
      ),
    );
  }
}
