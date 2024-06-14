part of 'all_players_bloc.dart';

sealed class AllPlayersEvent {}

class AllPlayersEventLoad extends AllPlayersEvent {
  final bool fromRuntimeCache;

  AllPlayersEventLoad({
    this.fromRuntimeCache = false,
  });
}
