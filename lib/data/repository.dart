import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../domain/models/player/player.dart';
import 'players_json.dart';

class PlayersRepository {
  List<PlayerModel> allPlayersCache = [];
  List<PlayerModel> savedPlayersCache = [];

  Future<List<PlayerModel>> getAllPlayers(bool fromRuntimeCache) async {
    if (fromRuntimeCache) {
      return allPlayersCache;
    }

    allPlayersCache = await compute<List<Map<String, Object>>, List<PlayerModel>>(
      _parsePlayer,
      allPlayers,
    );
    return allPlayersCache;
  }

  List<PlayerModel> _parsePlayer(List<Map<String, Object>> data) {
    return data.map((e) => PlayerModel.fromJson(e)).toList();
  }

  Future<void> savePlayers(List<PlayerModel> players) async {
    var box = await Hive.openBox<List<int>>('saved_players_ids');
    savedPlayersCache.addAll(players);
    savedPlayersCache.toSet().toList();
    box.put('players', savedPlayersCache.map((e) => e.id).toList());
  }

  Future<List<PlayerModel>> getSavedPlayers(bool fromRuntimeCache) async {
    if (fromRuntimeCache) {
      return savedPlayersCache;
    }

    var box = await Hive.openBox<List<int>>('saved_players_ids');
    final data = box.get('players', defaultValue: null);
    final players = await compute<List<int>?, List<PlayerModel>>(
      _parseSavedPlayerIds,
      data,
    );
    savedPlayersCache = players;
    return savedPlayersCache;
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
