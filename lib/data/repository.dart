import 'dart:math';

import 'package:euro_collect_app/data/players_json.dart';
import 'package:hive/hive.dart';

import '../domain/models/player/player.dart';

class PlayersRepository {
  final List<PlayerModel> savedPlayers = [];

  List<PlayerModel> getAllPlayers() {
    final result = <PlayerModel>[];
    for (var player in allPlayers) {
      result.add(PlayerModel.fromJson(player));
    }
    return result;
  }

  Future<void> savePlayer(PlayerModel player) async {
    var box = await Hive.openBox<List<int>>('saved_players_ids');
    savedPlayers.add(player);
    savedPlayers.toSet().toList();
    box.put('players', savedPlayers.map((e) => e.id).toList());
  }

  Future<List<PlayerModel>?> getSavedPlayers() async {
    var box = await Hive.openBox<List<int>>('saved_players_ids');
    final data = box.get('players', defaultValue: null);
    final result = <PlayerModel>[];
    for (final id in data ?? []) {
      result.add(PlayerModel.fromJson(allPlayers.firstWhere((player) => player['id'] == id)));
    }
    savedPlayers.addAll(result);
    return result;
  }

  List<PlayerModel> get10RandomPlayers() {
    final result = <PlayerModel>[];
    while (result.length < 10) {
      final player = _getRandomPlayer();
      if (!result.contains(player)) {
        result.add(player);
      }
    }

    return result;
  }

  PlayerModel _getRandomPlayer() {
    final index = Random().nextInt(allPlayers.length);
    return PlayerModel.fromJson(allPlayers[index]);
  }
}
