import 'package:flutter/material.dart';
import 'package:pomolocal/data/models/task_model.dart';
import 'package:pomolocal/data/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;

  List<Task> _tasks = [];
  Set<String> _categories = {};
  String _filterCategory = '';
  Task? _activeTask;

  TaskProvider(this._repository) {
    refresh();
  }

  List<Task> get tasks {
    if (_filterCategory.isEmpty) return _tasks;
    return _tasks.where((t) => t.category == _filterCategory).toList();
  }

  List<Task> get allTasks => _tasks;
  Set<String> get categories => _categories;
  String get filterCategory => _filterCategory;
  Task? get activeTask => _activeTask;

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.completed).length;
  int get activeCount => _tasks.where((t) => !t.completed).length;

  void setFilter(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setActiveTask(Task? task) {
    _activeTask = task;
    notifyListeners();
  }

  void incrementActiveTaskPomodoro() {
    if (_activeTask != null) {
      _activeTask!.pomodorosSpent++;
      // Hedefe ulaştıysa tamamla
      if (_activeTask!.pomodorosSpent >= _activeTask!.pomodorosTarget) {
        _activeTask!.completed = true;
      }
      _repository.save(_activeTask!);
      notifyListeners();
    }
  }

  Future<void> addTask(
    String title, {
    String category = '',
    int pomodorosTarget = 4,
    int focusDuration = 0,
    int shortBreak = 0,
    int colorValue = 0,
  }) async {
    final task = Task(
      title: title,
      category: category,
      order: _tasks.length,
      pomodorosTarget: pomodorosTarget,
      focusDuration: focusDuration,
      shortBreak: shortBreak,
      colorValue: colorValue,
    );
    await _repository.save(task);
    refresh();
  }

  Future<void> toggleTask(Task task) async {
    task.completed = !task.completed;
    await _repository.save(task);
    refresh();
  }

  Future<void> updateTask(
    Task task, {
    String? title,
    String? category,
    int? pomodorosTarget,
    int? focusDuration,
    int? shortBreak,
    int? colorValue,
    String? notes,
  }) async {
    if (title != null) task.title = title;
    if (category != null) task.category = category;
    if (pomodorosTarget != null) task.pomodorosTarget = pomodorosTarget;
    if (focusDuration != null) task.focusDuration = focusDuration;
    if (shortBreak != null) task.shortBreak = shortBreak;
    if (colorValue != null) task.colorValue = colorValue;
    if (notes != null) task.notes = notes;
    await _repository.save(task);
    refresh();
  }

  Future<void> deleteTask(String id) async {
    if (_activeTask?.id == id) _activeTask = null;
    await _repository.delete(id);
    refresh();
  }

  Future<void> clearCompleted() async {
    await _repository.deleteCompleted();
    refresh();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = tasks.toList();
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (var i = 0; i < list.length; i++) {
      list[i].order = i;
      await _repository.save(list[i]);
    }
    refresh();
  }

  void refresh() {
    _tasks = _repository.getAll();
    _categories = _repository.getCategories();
    // activeTask referansını güncelle
    if (_activeTask != null) {
      final updated = _tasks.where((t) => t.id == _activeTask!.id);
      _activeTask = updated.isNotEmpty ? updated.first : null;
    }
    notifyListeners();
  }
}
