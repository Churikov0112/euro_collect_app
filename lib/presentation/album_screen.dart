import 'package:euro_collect_app/domain/models/player/player.dart';
import 'package:euro_collect_app/presentation/blocs/all_players_bloc/all_players_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image/network.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      // drawer: Container(
      //   color: Colors.amber,
      //   height: mq.size.height,
      //   width: mq.size.width * 0.75,
      //   child: ListTile(
      //     onTap: () {
      //       Navigator.of(context).push(
      //         MaterialPageRoute<void>(
      //           builder: (BuildContext context) => const StickerPackScreen(),
      //         ),
      //       );
      //     },
      //   ),
      // ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const StickerPackScreen(),
            ),
          );
        },
        child: const Text("Открыть"),
      ),
      appBar: AppBar(
        title: const Text("Альбом"),
      ),
      body: BlocBuilder<AllPlayersBloc, AllPlayersState>(
        builder: (context, allPlayersState) {
          if (allPlayersState is AllPlayersStateLoadSucceeded) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              padding: const EdgeInsets.all(20),
              itemCount: allPlayersState.players.length,
              itemBuilder: (context, index) {
                return PlayerTile(player: allPlayersState.players[index]);
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class PlayerTile extends StatelessWidget {
  const PlayerTile({
    required this.player,
    super.key,
  });

  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      child: Image(
        image: NetworkImageWithRetry(player.photoUrl),
        fit: BoxFit.cover,
      ),
    );
  }
}
