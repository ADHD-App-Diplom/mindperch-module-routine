import 'package:mindperch_core/mindperch_core.dart';

/// A single step within a routine.
class RoutineStep extends BaseEntity implements TimeBlock {
  final String title;
  final String description;
  final int estimatedDurationMinutes;
  final int order;

  @override
  String get blockType => 'routineStep';

  @override
  TimeRange? get timeRange => null; // Steps are child blocks

  @override
  bool get isCompleted => false;

  @override
  int get frictionScore => 1;

  @override
  String get mentalLoad => 'low';

  @override
  int? get estimatedDuration => estimatedDurationMinutes;

  @override
  int? get actualDuration => null;

  @override
  String get categoryKey => 'routine_step';

  RoutineStep({
    required super.id,
    required this.title,
    this.description = '',
    required this.estimatedDurationMinutes,
    required this.order,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory RoutineStep.create({
    required String title,
    String description = '',
    required int estimatedDurationMinutes,
    required int order,
  }) {
    final now = DateTime.now().toUtc();
    return RoutineStep(
      id: generateId(),
      title: title,
      description: description,
      estimatedDurationMinutes: estimatedDurationMinutes,
      order: order,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    title,
    description,
    estimatedDurationMinutes,
    order,
  ];
}
