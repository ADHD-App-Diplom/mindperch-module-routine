import 'src/providers/routine_search_provider.dart';
import 'src/providers/routine_time_block_provider.dart';
import 'src/repositories/routine_repository.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:mindperch_module_api/mindperch_module_api.dart';
import 'package:mindperch_ui_api/mindperch_ui_api.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'src/models/routine_dto.dart';
import 'src/repositories/isar_routine_repository.dart';
import 'src/ui/routine_view.dart';
import 'package:mindperch_core/mindperch_core.dart';

class RoutineModuleInstaller implements ModuleInstaller {
  const RoutineModuleInstaller();

  @override
  ModuleMetadata get metadata => const ModuleMetadata(
    id: 'mindperch-routine',
    displayNameKey: 'routineTitle',
    descriptionKey: 'routineDescription',
    displayName: 'Routines',
    description: 'Step-by-step ADHD routines',
    iconData: Icons.repeat,
    linuxDependencies: [
      SystemDependency(
        name: 'GStreamer Audio',
        aptAlternatives: [
          'gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav',
        ],
        dnfAlternatives: [
          'gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-bad-free gstreamer1-plugins-ugly-free',
        ],
        pacmanAlternatives: [
          'gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav',
        ],
        description:
            'Required for audio playback when completing routine steps.',
      ),
    ],
  );
  @override
  List<dynamic> get isarSchemas => [RoutineDtoSchema];
  @override
  Future<List<SingleChildWidget>> install(
    DatabaseRegistry databases, {
    SyncRegistry? syncRegistry,
    TimeBlockRegistry? timeBlockRegistry,
    SearchRegistry? searchRegistry,
  }) async {
    final database = databases.require<Isar>();
    final repo = IsarRoutineRepository(database);

    if (timeBlockRegistry != null) {
      timeBlockRegistry.registerProvider(RoutineTimeBlockProvider(repo));
    }
    if (searchRegistry != null) {
      searchRegistry.registerProvider(RoutineSearchProvider(repo));
    }

    return [Provider<RoutineRepository>.value(value: repo)];
  }

  @override
  void registerUI(BuildContext context) {
    final layoutService = context.read<AbstractLayoutService>();
    layoutService.registerModuleView(
      'mindperch-routine',
      'default',
      (context) => const RoutineView(),
    );
  }
}
