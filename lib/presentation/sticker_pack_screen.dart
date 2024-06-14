import 'dart:math' as math;

import 'package:euro_collect_app/domain/models/player/player.dart';
import 'package:euro_collect_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

import '../ad_config.dart';
import 'player_card_widget.dart';

class StickerPackScreen extends StatefulWidget {
  const StickerPackScreen({super.key});

  @override
  StickerPackScreenState createState() => StickerPackScreenState();
}

class StickerPackScreenState extends State<StickerPackScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotateAnimation;

  bool _showCards = false;

  List<PlayerModel> packPlayers = [];
  final List<Widget> packPlayerCards = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    packPlayers = playersRepository.getRandomPlayers(5);
    for (var packPlayer in packPlayers) {
      packPlayerCards.add(PlayerPackCardWidget(player: packPlayer));
    }
    setState(() {});

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _loadAd();
      _adLoader = _createRewardedAdLoader();
      await _loadRewardedAd();
    });
  }

  // ! ads start ----------------------------------------------------------------

  late BannerAd banner;
  var isBannerAlreadyCreated = false;
  late final Future<RewardedAdLoader> _adLoader;
  RewardedAd? _ad;

  BannerAdSize _getBannerAdSize() {
    final width = MediaQuery.of(context).size.width.round();
    return BannerAdSize.sticky(width: width);
  }

  BannerAd _createBanner() {
    return BannerAd(
      adUnitId: adConfig.packBottomBanner, // "demo-banner-yandex",
      adSize: _getBannerAdSize(),
      adRequest: const AdRequest(),
      onAdLoaded: () {
        if (!mounted) {
          banner.destroy();
          return;
        }
      },
    );
  }

  void _loadAd() async {
    banner = _createBanner();
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
        onRewarded: (reward) {},
      ),
    );

    await _ad?.show();
    final reward = await _ad?.waitForDismiss();
    if (reward != null) {
      _openPack();
    }
  }

  // ! ads end ---------------------------------------------------------------

  @override
  void dispose() {
    _controller.dispose();
    _ad?.destroy();
    super.dispose();
  }

  Future<void> _openPack() async {
    for (var item in packPlayers) {
      await playersRepository.savePlayer(item);
    }
    setState(() {
      _showCards = true;
    });
    _controller.forward();
  }

  void _removeCard(int i) {
    packPlayerCards.removeLast();
    setState(() {});
    if (i == 0) {
      _closePack();
    }
  }

  void _closePack() {
    setState(() {
      _showCards = false;
    });
    _controller.reverse().whenComplete(() {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 35, 43, 56),
      body: Stack(
        children: [
          if (_showCards)
            for (int i = 0; i < packPlayerCards.length; i++)
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) => Positioned(
                  top: 400 - _slideAnimation.value * 300,
                  child: SizedBox(
                    width: mq.size.width,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 200,
                            child: Dismissible(
                              key: UniqueKey(),
                              onDismissed: (direction) {
                                _removeCard(i);
                              },
                              child: packPlayerCards[i],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) => Positioned(
              top: 100 + _slideAnimation.value * 100,
              child: SizedBox(
                width: mq.size.width,
                height: mq.size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _rotateAnimation,
                      builder: (context, child) => Transform(
                        transform: Matrix4.identity()..rotateZ(_rotateAnimation.value * -1 * math.pi * 0.03),
                        origin: const Offset(1.0, 1.0),
                        child: Container(
                          width: 200,
                          height: 10,
                          color: const Color.fromRGBO(43, 92, 255, 1),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_showCards == false) {
                          final randomDouble = math.Random().nextInt(6);
                          final showAd = randomDouble > 3;
                          if (showAd) {
                            _showRewardedAd();
                          } else {
                            _openPack();
                          }
                        }
                      },
                      onVerticalDragEnd: (details) {
                        if (_showCards == false) {
                          final randomDouble = math.Random().nextInt(6);
                          final showAd = randomDouble > 3;
                          if (showAd) {
                            _showRewardedAd();
                          } else {
                            _openPack();
                          }
                        }
                      },
                      child: Container(
                        height: 300,
                        width: 200,
                        color: const Color.fromRGBO(43, 92, 255, 1),
                        child: Image.asset("assets/euro-2024-pix.jpg", fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (!_showCards)
                      GestureDetector(
                        onTap: () {
                          if (_showCards == false) {
                            final randomDouble = math.Random().nextInt(6);
                            final showAd = randomDouble > 3;
                            if (showAd) {
                              _showRewardedAd();
                            } else {
                              _openPack();
                            }
                          }
                        },
                        child: const Text(
                          "Tap pack to open",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            fontSize: 32,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (isBannerAlreadyCreated)
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: AdWidget(bannerAd: banner),
            ),
        ],
      ),
    );
  }
}
