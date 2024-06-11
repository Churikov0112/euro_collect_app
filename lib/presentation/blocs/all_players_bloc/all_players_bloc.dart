import 'package:euro_collect_app/data/repository.dart';
import 'package:euro_collect_app/domain/models/player/player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'all_players_event.dart';
part 'all_players_state.dart';

class AllPlayersBloc extends Bloc<AllPlayersEvent, AllPlayersState> {
  final PlayersRepository repository;

  AllPlayersBloc({
    required this.repository,
  }) : super(AllPlayersStateInitial()) {
    on<AllPlayersEvent>((event, emit) {
      if (event is AllPlayersEventLoad) {
        _load(event, emit);
      }
    });
  }

  void _load(AllPlayersEventLoad event, Emitter emit) {
    try {
      emit(AllPlayersStatePending());
      final players = repository.getAllPlayers();
      emit(AllPlayersStateLoadSucceeded(players: players));
    } catch (e) {
      emit(AllPlayersStateFailed(message: e.toString()));
    }
  }
}
