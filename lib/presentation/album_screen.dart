import 'package:euro_collect_app/domain/models/player/player.dart';
import 'package:euro_collect_app/presentation/blocs/all_players_bloc/all_players_bloc.dart';
import 'package:euro_collect_app/presentation/blocs/saved_players_bloc/saved_players_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'player_card_widget.dart';
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
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   _loadAd();
    // });
    super.initState();
  }

  // ! ads start ----------------------------------------------------------------
  // late BannerAd banner;
  // var isBannerAlreadyCreated = false;

  // BannerAdSize _getBannerAdSize() {
  //   final width = MediaQuery.of(context).size.width.round();
  //   return BannerAdSize.sticky(width: width);
  // }

  // BannerAd _createBanner() {
  //   return BannerAd(
  //     adUnitId: adConfig.albumBottomBanner, // "demo-banner-yandex",
  //     adSize: _getBannerAdSize(),
  //     adRequest: const AdRequest(),
  //     onAdLoaded: () {
  //       if (!mounted) {
  //         banner.destroy();
  //         return;
  //       }
  //     },
  //   );
  // }

  // _loadAd() async {
  //   banner = _createBanner();
  //   setState(() {
  //     isBannerAlreadyCreated = true;
  //   });
  // }

  _updatePage() {
    print("update");
    context.read<AllPlayersBloc>().add(AllPlayersEventLoad(fromRuntimeCache: true));
    context.read<SavedPlayersBloc>().add(SavedPlayersEventLoad(fromRuntimeCache: true));
  }

  // ! ads end ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // final mq = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Euro Pack Collection",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color.fromRGBO(43, 92, 255, 1),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const StickerPackScreen(),
                    ),
                  )
                  .whenComplete(_updatePage);
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(43, 92, 255, 1),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: const Icon(Icons.refresh),
      // ),
      body: Stack(
        children: [
          BlocBuilder<SavedPlayersBloc, SavedPlayersState>(
            builder: (context, savedPlayersState) => BlocBuilder<AllPlayersBloc, AllPlayersState>(
              builder: (context, allPlayersState) {
                if (allPlayersState is AllPlayersStateLoadSucceeded &&
                    savedPlayersState is SavedPlayersStateLoadSucceeded) {
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
                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 120),
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
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
            ),
          ),
          // if (isBannerAlreadyCreated)
          //   Positioned(
          //     bottom: 0,
          //     right: 0,
          //     left: 0,
          //     child: AdWidget(bannerAd: banner),
          //   ),
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
        Navigator.of(context)
            .push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const StickerPackScreen(),
          ),
        )
            .whenComplete(() {
          print("update");
          context.read<AllPlayersBloc>().add(AllPlayersEventLoad(fromRuntimeCache: true));
          context.read<SavedPlayersBloc>().add(SavedPlayersEventLoad(fromRuntimeCache: true));
        });
      },
      child: Container(
        color: Colors.grey[300],
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                player.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox.shrink(),
              Opacity(
                opacity: 0.3,
                child: Text(
                  getCountryEmoji(player),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              Text(
                player.id.toString(),
                style: const TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.bold,
                  color: Colors.black26,
                ),
              ),
            ],
          ),
        ),
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
