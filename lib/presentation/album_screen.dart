import 'package:euro_collect_app/domain/models/player/player.dart';
import 'package:euro_collect_app/presentation/blocs/all_players_bloc/all_players_bloc.dart';
import 'package:euro_collect_app/presentation/blocs/saved_players_bloc/saved_players_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

import 'sticker_pack_screen.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  @override
  void initState() {
    context.read<AllPlayersBloc>().add(AllPlayersEventLoad());
    context.read<SavedPlayersBloc>().add(SavedPlayersEventLoad());
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
    super.initState();
  }

  // ! ads start ----------------------------------------------------------------
  late BannerAd banner;
  var isBannerAlreadyCreated = false;

  BannerAdSize _getBannerAdSize() {
    final width = MediaQuery.of(context).size.width.round();
    return BannerAdSize.sticky(width: width);
  }

  BannerAd _createBanner() {
    return BannerAd(
      adUnitId: "R-M-9326097-1", // "demo-banner-yandex",
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

  _loadAd() async {
    banner = _createBanner();
    setState(() {
      isBannerAlreadyCreated = true;
    });
  }

  // ! ads end ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // final mq = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Album")),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: const Icon(Icons.refresh),
      // ),
      body: Stack(
        children: [
          BlocBuilder<AllPlayersBloc, AllPlayersState>(
            builder: (context, allPlayersState) {
              if (allPlayersState is AllPlayersStateLoadSucceeded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    Future.delayed(const Duration(milliseconds: 500)).whenComplete(() {
                      context.read<AllPlayersBloc>().add(AllPlayersEventLoad());
                      context.read<SavedPlayersBloc>().add(SavedPlayersEventLoad());
                    });
                  },
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 2 / 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    padding: const EdgeInsets.all(20),
                    itemCount: allPlayersState.players.length,
                    itemBuilder: (context, index) {
                      return PlayerCard(
                        player: allPlayersState.players[index],
                      );
                    },
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
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

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    required this.player,
    super.key,
  });

  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    final absentWIdget = GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const StickerPackScreen(),
          ),
        );
      },
      child: Container(
        color: Colors.grey[400],
        child: const Icon(Icons.question_mark, size: 40),
      ),
    );

    return BlocBuilder<SavedPlayersBloc, SavedPlayersState>(
      buildWhen: (previous, current) => current is SavedPlayersStateLoadSucceeded,
      builder: (context, savedPlayersState) {
        if (savedPlayersState is SavedPlayersStateLoadSucceeded) {
          final isPlayerSaved = savedPlayersState.players.contains(player);
          if (isPlayerSaved) {
            return PlayerPackCardWidget(player: player);
          }
        }
        return absentWIdget;
      },
    );
  }
}
