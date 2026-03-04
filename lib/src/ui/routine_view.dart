import 'package:mindperch_ui_api/mindperch_ui_api.dart';
import '../repositories/routine_repository.dart';
import '../models/routine_step.dart';
import '../models/routine.dart';






import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';


class RoutineView extends StatefulWidget {
  const RoutineView({super.key});

  @override
  State<RoutineView> createState() => _RoutineViewState();
}

class _RoutineViewState extends State<RoutineView> {
  Routine? _activeRoutine;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<RoutineRepository>();

    if (_activeRoutine != null) {
      return _RoutinePlayer(
        routine: _activeRoutine!,
        onClose: () => setState(() => _activeRoutine = null),
      );
    }

    return ModuleScaffold(
      title: 'Routines',
      body: StreamBuilder<List<Routine>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          final routines = snapshot.data ?? [];
          if (routines.isEmpty)
            return const Center(
              child: Text('Add a routine to build momentum.'),
            );
          return ListView.builder(
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final r = routines[index];
              return ListTile(
                title: Text(r.title),
                subtitle: Text(
                  '${r.steps.length} steps • ${r.targetStartTime.hour}:${r.targetStartTime.minute.toString().padLeft(2, "0")}',
                ),
                trailing: const Icon(Icons.play_arrow, color: Colors.green),
                onTap: () => setState(() => _activeRoutine = r),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomRoutineBuilder(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  
  void _showCustomRoutineBuilder(BuildContext context) {
    final titleCtrl = TextEditingController();
    final List<RoutineStep> currentSteps = [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Create Custom Routine'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Routine Name', hintText: 'e.g. Morning Workout'),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: currentSteps.isEmpty 
                    ? const Center(child: Text('No steps yet. Add one below.'))
                    : ReorderableListView.builder(
                        shrinkWrap: true,
                        itemCount: currentSteps.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = currentSteps.removeAt(oldIndex);
                          currentSteps.insert(newIndex, item);
                          // Re-assign order
                          for (int i = 0; i < currentSteps.length; i++) {
                            currentSteps[i] = RoutineStep.create(title: currentSteps[i].title, estimatedDurationMinutes: currentSteps[i].estimatedDurationMinutes, order: i);
                          }
                          setState(() {});
                        },
                        itemBuilder: (context, index) {
                          final step = currentSteps[index];
                          return ListTile(
                            key: ValueKey(step.id),
                            title: Text(step.title),
                            subtitle: Text('${step.estimatedDurationMinutes} min'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setState(() => currentSteps.removeAt(index)),
                            ),
                          );
                        }
                    ),
                ),
                const Divider(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Step'),
                  onPressed: () {
                    _showAddStepDialog(ctx, (stepTitle, mins) {
                      setState(() {
                        currentSteps.add(RoutineStep.create(
                          title: stepTitle,
                          estimatedDurationMinutes: mins,
                          order: currentSteps.length,
                        ));
                      });
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty && currentSteps.isNotEmpty) {
                  final repo = context.read<RoutineRepository>();
                  repo.save(Routine.create(
                    title: titleCtrl.text,
                    targetStartTime: DateTime.now(),
                    steps: currentSteps,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Routine'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStepDialog(BuildContext context, Function(String, int) onAdd) {
    final stepCtrl = TextEditingController();
    final minCtrl = TextEditingController(text: '5');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Step'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stepCtrl,
              decoration: const InputDecoration(labelText: 'Step Title'),
              autofocus: true,
            ),
            TextField(
              controller: minCtrl,
              decoration: const InputDecoration(labelText: 'Duration (minutes)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (stepCtrl.text.isNotEmpty) {
                final mins = int.tryParse(minCtrl.text) ?? 5;
                onAdd(stepCtrl.text, mins);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      )
    );
  }

  void _showTemplatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text(
              'Select a Template',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: const Text('Morning Power-Up'),
            onTap: () {
              Navigator.pop(ctx);
              _addRoutineFromTemplate('Morning Power-Up', [
                RoutineStep.create(
                  title: 'Hydrate',
                  estimatedDurationMinutes: 2,
                  order: 0,
                ),
                RoutineStep.create(
                  title: 'Light Stretch',
                  estimatedDurationMinutes: 5,
                  order: 1,
                ),
                RoutineStep.create(
                  title: 'Check Today\'s Tasks',
                  estimatedDurationMinutes: 3,
                  order: 2,
                ),
              ]);
            },
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Focus Setup'),
            onTap: () {
              Navigator.pop(ctx);
              _addRoutineFromTemplate('Focus Setup', [
                RoutineStep.create(
                  title: 'Clear Desk',
                  estimatedDurationMinutes: 5,
                  order: 0,
                ),
                RoutineStep.create(
                  title: 'Noise Cancelling On',
                  estimatedDurationMinutes: 1,
                  order: 1,
                ),
                RoutineStep.create(
                  title: 'Set One Goal',
                  estimatedDurationMinutes: 2,
                  order: 2,
                ),
              ]);
            },
          ),
          ListTile(
            leading: const Icon(Icons.nightlight_outlined),
            title: const Text('Shutdown Sequence'),
            onTap: () {
              Navigator.pop(ctx);
              _addRoutineFromTemplate('Shutdown Sequence', [
                RoutineStep.create(
                  title: 'Review Achievements',
                  estimatedDurationMinutes: 5,
                  order: 0,
                ),
                RoutineStep.create(
                  title: 'Clear Inbox',
                  estimatedDurationMinutes: 5,
                  order: 1,
                ),
                RoutineStep.create(
                  title: 'Write Top 3 for Tomorrow',
                  estimatedDurationMinutes: 5,
                  order: 2,
                ),
              ]);
            },
          ),
        ],
      ),
    );
  }

  void _addRoutineFromTemplate(String title, List<RoutineStep> steps) {
    final repo = context.read<RoutineRepository>();
    final r = Routine.create(
      title: title,
      targetStartTime: DateTime.now(),
      steps: steps,
    );
    repo.save(r);
  }
}

class _RoutinePlayer extends StatefulWidget {
  final Routine routine;
  final VoidCallback onClose;
  const _RoutinePlayer({required this.routine, required this.onClose});

  @override
  State<_RoutinePlayer> createState() => _RoutinePlayerState();
}

class _RoutinePlayerState extends State<_RoutinePlayer> {
  int _stepIdx = 0;
  int _secondsLeft = 0;
  Timer? _timer;
  

  @override
  void initState() {
    super.initState();
    _startStep(0);
  }

  void _startStep(int index) {
    setState(() {
      _stepIdx = index;
      _secondsLeft = widget.routine.steps[index].estimatedDurationMinutes * 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _onStepComplete();
      }
    });
  }

  void _onStepComplete() async {
    _timer?.cancel();
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }

    

    if (_stepIdx < widget.routine.steps.length - 1) {
      _startStep(_stepIdx + 1);
    } else {
      widget.onClose();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.routine.steps[_stepIdx];
    final total = widget.routine.steps.length;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: LinearProgressIndicator(
              value: (_stepIdx + 1) / total,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 80),
          Text(
            'STEP ${_stepIdx + 1} OF $total',
            style: const TextStyle(color: Colors.grey, letterSpacing: 3),
          ),
          const SizedBox(height: 16),
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Text(
            '${_secondsLeft ~/ 60}:${(_secondsLeft % 60).toString().padLeft(2, "0")}',
            style: const TextStyle(
              fontSize: 100,
              fontFamily: 'monospace',
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(height: 80),
          ElevatedButton(
            onPressed: _onStepComplete,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(220, 70),
              backgroundColor: Colors.green,
            ),
            child: Text(
              _stepIdx < total - 1 ? 'NEXT STEP' : 'DONE',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
