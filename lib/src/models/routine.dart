import 'routine_step.dart';
import 'package:mindperch_core/mindperch_core.dart';

/// A set of sequential steps to be performed at a specific time.
class Routine extends BaseEntity implements TimeBlock {
  final String title;
  final String description;
  final DateTime targetStartTime;
  final RecurrenceRule? recurrenceRule;
  final List<RoutineStep> steps;

  @override
  String get blockType => 'routine';

  @override
  TimeRange? get timeRange {
    final totalDuration = steps.fold(
      0,
      (sum, step) => sum + step.estimatedDurationMinutes,
    );
    return TimeRange(
      start: targetStartTime,
      end: targetStartTime.add(Duration(minutes: totalDuration)),
    );
  }

  @override
  bool get isCompleted => false; // Routines are completed step-by-step

  @override
  int get frictionScore => 3;

  @override
  String get mentalLoad => 'low';

  @override
  int? get estimatedDuration =>
      steps.fold<int>(0, (sum, step) => sum + step.estimatedDurationMinutes);

  @override
  int? get actualDuration => null; // To be implemented with tracking

  @override
  String get categoryKey => 'routine';

  Routine({
    required super.id,
    required this.title,
    this.description = '',
    required this.targetStartTime,
    this.recurrenceRule,
    this.steps = const [],
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory Routine.create({
    required String title,
    String description = '',
    required DateTime targetStartTime,
    RecurrenceRule? recurrenceRule,
    List<RoutineStep> steps = const [],
  }) {
    final now = DateTime.now().toUtc();
    return Routine(
      id: generateId(),
      title: title,
      description: description,
      targetStartTime: targetStartTime,
      recurrenceRule: recurrenceRule,
      steps: steps,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    title,
    description,
    targetStartTime,
    recurrenceRule,
    steps,
  ];
}
