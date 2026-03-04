import '../models/routine.dart';
import 'package:mindperch_core/mindperch_core.dart';

abstract class RoutineRepository {
  Future<void> save(Routine routine);
  Future<void> delete(String id);
  Future<Routine?> getById(String id);
  Future<List<Routine>> getAll();
  Stream<List<Routine>> watchAll();
}
