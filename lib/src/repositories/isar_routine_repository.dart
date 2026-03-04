import '../models/routine.dart';
import '../models/routine_step.dart';
import 'routine_repository.dart';
import 'package:mindperch_isar/mindperch_isar.dart';
import '../models/routine_dto.dart';
class IsarRoutineRepository extends IsarStorage<Routine, RoutineDto> implements RoutineRepository {
  IsarRoutineRepository(super.isar);
  @override IsarCollection<RoutineDto> get collection => isar.routineDtos;
  @override Routine mapToDomain(RoutineDto dto) => Routine(
      id: dto.uuid, title: dto.title, description: dto.description,
      targetStartTime: dto.targetStartTime,
      steps: dto.steps.map((s) => RoutineStep(
        id: s.uuid, title: s.title, description: s.description,
        estimatedDurationMinutes: s.estimatedDurationMinutes, order: s.order,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      )).toList(),
      createdAt: dto.createdAt ?? DateTime.now(), updatedAt: dto.updatedAt ?? DateTime.now(),
  );
  @override RoutineDto mapToDto(Routine entity) => RoutineDto()
      ..uuid = entity.id ..title = entity.title ..description = entity.description
      ..targetStartTime = entity.targetStartTime
      ..steps = entity.steps.map((s) => RoutineStepDto()
        ..uuid = s.id ..title = s.title ..description = s.description
        ..estimatedDurationMinutes = s.estimatedDurationMinutes ..order = s.order).toList()
      ..createdAt = entity.createdAt ..updatedAt = entity.updatedAt;
  @override Future<RoutineDto?> findByUuid(String uuid) => isar.routineDtos.filter().uuidEqualTo(uuid).findFirst();
  @override Future<void> performDelete(RoutineDto dto) => isar.routineDtos.delete(dto.id);
  @override Future<Routine?> getById(String id) => getByUuid(id);
  @override Future<List<Routine>> getAll() async { final dtos = await collection.where().findAll(); return dtos.map(mapToDomain).toList(); }
}
