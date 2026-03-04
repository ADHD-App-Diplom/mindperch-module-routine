import 'package:mindperch_core/mindperch_core.dart';
import '../repositories/routine_repository.dart';

class RoutineTimeBlockProvider implements TimeBlockProvider {
  final RoutineRepository _repository;

  RoutineTimeBlockProvider(this._repository);

  @override
  Stream<List<TimeBlock>> getTimeBlocksStream() {
    return _repository.watchAll().map((routines) => routines.cast<TimeBlock>());
  }

  @override
  Future<List<TimeBlock>> getTimeBlocks() async {
    final routines = await _repository.getAll();
    return routines.cast<TimeBlock>();
  }
}
