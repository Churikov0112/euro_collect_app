import 'package:euro_collect_app/data/players_json.dart';

import '../domain/models/player.dart';

class PlayersRepository {
  List<PlayerModel> getAllPlayers() {
    final result = <PlayerModel>[];
    for (var player in allPlayers) {
      result.add(PlayerModel.fromJson(player));
    }
    return result;
  }
}
