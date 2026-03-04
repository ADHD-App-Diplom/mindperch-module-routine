import 'package:mindperch_core/mindperch_core.dart';
import '../repositories/routine_repository.dart';

class RoutineSearchProvider implements SearchProvider {
  final RoutineRepository _repository;

  RoutineSearchProvider(this._repository);

  @override
  String get moduleType => 'mindperch-routine';

  @override
  Future<List<SearchResult>> search(String query) async {
    final routines = await _repository.getAll();
    return routines
        .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
        .map(
          (r) => SearchResult(
            id: r.id,
            title: r.title,
            subtitle: r.description,
            moduleType: moduleType,
            payload: r,
          ),
        )
        .toList();
  }
}
