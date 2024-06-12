import 'dart:math' as math;

import 'package:euro_collect_app/domain/models/player/player.dart';
import 'package:euro_collect_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_image/network.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

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

    packPlayers = playersRepository.get5RandomPlayers();
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
      adUnitId: "R-M-9326097-2", // "demo-banner-yandex",
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
      adRequestConfiguration: const AdRequestConfiguration(
        adUnitId: 'R-M-9326097-3', // 'demo-rewarded-yandex',
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

  void _openPack() {
    setState(() {
      _showCards = true;
    });
    _controller.forward().whenComplete(() {});
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
      body: Stack(
        children: [
          if (_showCards)
            for (int i = 0; i < packPlayerCards.length; i++)
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) => Positioned(
                  right: 100,
                  left: 100,
                  top: 400 - _slideAnimation.value * 300,
                  child: Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction) {
                      playersRepository.savePlayer(packPlayers[i]);
                      _removeCard(i);
                    },
                    child: packPlayerCards[i],
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
                      onTap: _showCards ? _closePack : _showRewardedAd,
                      onVerticalDragEnd: (details) {
                        if (_showCards == false) {
                          _showRewardedAd();
                        }
                      },
                      child: Container(
                        height: 300,
                        width: 200,
                        color: const Color.fromRGBO(43, 92, 255, 1),
                        child: Image.asset("assets/euro-2024-pix.jpg", fit: BoxFit.contain),
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
              child: AdWidget(bannerAd: banner),
            ),
        ],
      ),
    );
  }
}

class PlayerPackCardWidget extends StatelessWidget {
  const PlayerPackCardWidget({
    required this.player,
    super.key,
  });

  final PlayerModel player;

  String getCountryEmoji() {
    switch (player.countryName) {
      case "Германия":
        return "🇩🇪";
      case "Шотландия":
        return "🏴󠁧󠁢󠁳󠁣󠁴󠁿";
      case "Швейцария":
        return "🇨🇭";
      case "Венгрия":
        return "🇭🇺";
      case "Испания":
        return "🇪🇸";
      case "Италия":
        return "🇮🇹";
      case "Хорватия":
        return "🇭🇷";
      case "Албания":
        return "🇦🇱";
      case "Англия":
        return "🏴󠁧󠁢󠁥󠁮󠁧󠁿";
      case "Сербия":
        return "🇷🇸";
      case "Дания":
        return "🇩🇰";
      case "Словения":
        return "🇸🇮";
      case "Франция":
        return "🇫🇷";
      case "Нидерланды":
        return "🇳🇱";
      case "Австрия":
        return "🇦🇹";
      case "Польша":
        return "🇵🇱";
      case "Бельгия":
        return "🇧🇪";
      case "Румыния":
        return "🇷🇴";
      case "Словакия":
        return "🇸🇰";
      case "Украина":
        return "🇺🇦";
      case "Португалия":
        return "🇵🇹";
      case "Турция":
        return "🇹🇷";
      case "Чехия":
        return "🇨🇿";
      case "Грузия":
        return "🇬🇪";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final imageUrl = player.photoUrl.contains("medium") ? player.photoUrl.replaceAll("medium", "big") : player.photoUrl;

    return Container(
      height: 300,
      width: 200,
      decoration: BoxDecoration(
        border: Border.all(),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            bottom: 30,
            child: Image(
              image: NetworkImageWithRetry(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 5,
            left: 5,
            child: Row(
              children: [
                Text(
                  getCountryEmoji(),
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Row(
              children: [
                DecoratedBox(
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage("assets/shirt.png")),
                  ),
                  child: SizedBox(
                    height: 32,
                    width: 32,
                    child: Center(
                      child: Text(
                        player.number.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5, bottom: 5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(),
                    ),
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: Center(
                        child: Text(
                          player.position,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: BorderDirectional(top: BorderSide()),
                  ),
                  child: SizedBox(
                    width: mq.size.width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
