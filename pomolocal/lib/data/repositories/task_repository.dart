import 'package:hive/hive.dart';
import 'package:pomolocal/data/models/task_model.dart';

class TaskRepository {
  final Box<Task> _box;

  TaskRepository(this._box);

  Future<void> save(Task task) async {
    await _box.put(task.id, task);
  }

  List<Task> getAll() {
    return _box.values.toList()..sort((a, b) {
      // Tamamlanmayanlar önce, sonra sıraya göre
      if (a.completed != b.completed) return a.completed ? 1 : -1;
      return a.order.compareTo(b.order);
    });
  }

  List<Task> getByCategory(String category) {
    return getAll().where((t) => t.category == category).toList();
  }

  List<Task> getActive() {
    return _box.values.where((t) => !t.completed).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Set<String> getCategories() {
    return _box.values
        .map((t) => t.category)
        .where((c) => c.isNotEmpty)
        .toSet();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteCompleted() async {
    final completed = _box.values.where((t) => t.completed).toList();
    for (final t in completed) {
      await _box.delete(t.id);
    }
  }
}
