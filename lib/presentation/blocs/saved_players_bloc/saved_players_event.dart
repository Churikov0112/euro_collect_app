part of 'saved_players_bloc.dart';

sealed class SavedPlayersEvent {}

class SavedPlayersEventLoad extends SavedPlayersEvent {
  final bool fromRuntimeCache;

  SavedPlayersEventLoad({
    this.fromRuntimeCache = false,
  });
}
