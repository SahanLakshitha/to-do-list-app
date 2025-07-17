import 'package:flutter/material.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/models/task_model.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository;
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  String? _currentFilter;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String? get currentFilter => _currentFilter;

  List<Task> get tasks => _filteredTasks.isEmpty ? _tasks : _filteredTasks;

  TaskViewModel(this._repository);

  Future<void> loadTasks() async {
    _tasks = await _repository.getAllTasks();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _repository.addTask(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(taskId);
    await loadTasks();
  }

  void searchTasks(String query) {
    if (query.isEmpty) {
      _filteredTasks = [];
    } else {
      _filteredTasks = _tasks
          .where(
              (task) => task.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterByCategory(String? category) {
    if (category == null) {
      _filteredTasks = [];
    } else {
      _filteredTasks =
          _tasks.where((task) => task.category == category).toList();
    }
    notifyListeners();
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    final List<Task> reorderedTasks = List.from(_tasks);
    final Task movedTask = reorderedTasks.removeAt(oldIndex);
    reorderedTasks.insert(newIndex, movedTask);
    await _repository.reorderTasks(reorderedTasks);
    await loadTasks();
  }
}
