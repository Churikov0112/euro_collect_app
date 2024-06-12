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
    on<AllPlayersEvent>((event, emit) async {
      if (event is AllPlayersEventLoad) {
        await _load(event, emit);
      }
    });
  }

  Future<void> _load(AllPlayersEventLoad event, Emitter emit) async {
    try {
      emit(AllPlayersStatePending());
      await Future.delayed(const Duration(milliseconds: 500));
      final players = repository.getAllPlayers();
      emit(AllPlayersStateLoadSucceeded(players: players));
    } catch (e) {
      emit(AllPlayersStateFailed(message: e.toString()));
    }
  }
}
