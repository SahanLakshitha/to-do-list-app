import 'package:hive/hive.dart';
import '../models/task_model.dart';

class TaskRepository {
  final Box<Task> _taskBox;

  TaskRepository(this._taskBox);

  Future<List<Task>> getAllTasks() async {
    return _taskBox.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<void> addTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
  }

  Future<List<Task>> searchTasks(String query) async {
    return _taskBox.values
        .where((task) => task.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> reorderTasks(List<Task> tasks) async {
    final batch = _taskBox.watch();
    for (int i = 0; i < tasks.length; i++) {
      batch.put(tasks[i].id, tasks[i].copyWith(sortOrder: i));
    }
    await batch.commit();
  }
}

extension on Stream<BoxEvent> {
  void put(String id, Task copyWith) {}

  commit() {}
}
