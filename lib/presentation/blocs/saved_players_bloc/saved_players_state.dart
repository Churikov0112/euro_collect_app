part of 'saved_players_bloc.dart';

sealed class SavedPlayersState {}

final class SavedPlayersStateInitial extends SavedPlayersState {}

final class SavedPlayersStatePending extends SavedPlayersState {}

final class SavedPlayersStateLoadSucceeded extends SavedPlayersState {
  final List<PlayerModel> players;

  SavedPlayersStateLoadSucceeded({
    required this.players,
  });
}

final class SavedPlayersStateFailed extends SavedPlayersState {
  final String message;

  SavedPlayersStateFailed({
    required this.message,
  });
}
