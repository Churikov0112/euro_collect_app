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
    var box = await Hive.openBox<List<Map<dynamic, dynamic>>>('saved_players');
    savedPlayers.add(player);
    savedPlayers.toSet().toList();
    box.put('players', savedPlayers.map((e) => e.toJson()).toList());
  }

  Future<List<PlayerModel>?> getSavedPlayers() async {
    var box = await Hive.openBox<List<Map<dynamic, dynamic>>>('saved_players');
    final data = box.get('players');
    final result = data?.map((e) => PlayerModel.fromJson(e)).toList();
    return result;
  }
}
