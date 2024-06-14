import 'dart:math';

import 'package:euro_collect_app/data/players_json.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../domain/models/player/player.dart';

class PlayersRepository {
  List<PlayerModel> savedPlayers = [];

  List<PlayerModel> getAllPlayers() {
    return allPlayers.map((e) => PlayerModel.fromJson(e)).toList();
  }

  Future<void> savePlayer(PlayerModel player) async {
    var box = await Hive.openBox<List<int>>('saved_players_ids');
    savedPlayers.add(player);
    savedPlayers.toSet().toList();
    box.put('players', savedPlayers.map((e) => e.id).toList());
  }

  Future<List<PlayerModel>> getSavedPlayers() async {
    var box = await Hive.openBox<List<int>>('saved_players_ids');
    final data = box.get('players', defaultValue: null);
    final players = await compute<List<int>?, List<PlayerModel>>(
      _parseSavedPlayerIds,
      data,
    );
    savedPlayers = players;
    return savedPlayers;
  }

  List<PlayerModel> _parseSavedPlayerIds(List<int>? ids) {
    final result = <PlayerModel>[];
    for (final id in ids ?? []) {
      result.add(PlayerModel.fromJson(allPlayers.firstWhere((player) => player['id'] == id)));
    }
    return result;
  }

  List<PlayerModel> getRandomPlayers(int count) {
    final result = <PlayerModel>[];
    while (result.length < count) {
      final player = _getRandomPlayer();
      result.add(player);
    }

    return result;
  }

  PlayerModel _getRandomPlayer() {
    final index = Random().nextInt(allPlayers.length);
    return PlayerModel.fromJson(allPlayers[index]);
  }
}
