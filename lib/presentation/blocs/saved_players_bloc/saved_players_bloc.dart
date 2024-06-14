import 'package:euro_collect_app/data/repository.dart';
import 'package:euro_collect_app/domain/models/player/player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'saved_players_event.dart';
part 'saved_players_state.dart';

class SavedPlayersBloc extends Bloc<SavedPlayersEvent, SavedPlayersState> {
  final PlayersRepository repository;

  SavedPlayersBloc({
    required this.repository,
  }) : super(SavedPlayersStateInitial()) {
    on<SavedPlayersEvent>((event, emit) async {
      if (event is SavedPlayersEventLoad) {
        await _load(event, emit);
      }
    });
  }

  Future<void> _load(SavedPlayersEventLoad event, Emitter emit) async {
    try {
      emit(SavedPlayersStatePending());
      final players = await repository.getSavedPlayers();
      emit(SavedPlayersStateLoadSucceeded(players: players));
    } catch (e) {
      emit(SavedPlayersStateFailed(message: e.toString()));
    }
  }
}
