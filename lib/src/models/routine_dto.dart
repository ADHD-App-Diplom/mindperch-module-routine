import 'package:isar_community/isar.dart';
part 'routine_dto.g.dart';
@collection
class RoutineDto {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String uuid;
  late String title;
  late String description;
  late DateTime targetStartTime;
  late List<RoutineStepDto> steps;
  DateTime? createdAt;
  DateTime? updatedAt;
}
@embedded
class RoutineStepDto {
  late String uuid;
  late String title;
  late String description;
  late int estimatedDurationMinutes;
  late int order;
}
