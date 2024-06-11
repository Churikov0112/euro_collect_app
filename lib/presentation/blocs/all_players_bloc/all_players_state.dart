part of 'all_players_bloc.dart';

sealed class AllPlayersState {}

final class AllPlayersStateInitial extends AllPlayersState {}

final class AllPlayersStatePending extends AllPlayersState {}

final class AllPlayersStateLoadSucceeded extends AllPlayersState {
  final List<PlayerModel> players;

  AllPlayersStateLoadSucceeded({
    required this.players,
  });
}

final class AllPlayersStateFailed extends AllPlayersState {
  final String message;

  AllPlayersStateFailed({
    required this.message,
  });
}
