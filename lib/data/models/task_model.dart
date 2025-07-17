import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final DateTime dueDate;
  @HiveField(4)
  final Priority priority;
  @HiveField(5)
  bool isCompleted;
  @HiveField(6)
  final List<Subtask> subtasks;
  @HiveField(7)
  final String category;
  @HiveField(8)
  int sortOrder;

  Task({
    String? id,
    required this.title,
    this.description,
    required this.dueDate,
    this.priority = Priority.Medium,
    this.isCompleted = false,
    this.subtasks = const [],
    required this.category,
    this.sortOrder = 0,
  }) : id = id ?? const Uuid().v4();

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
    List<Subtask>? subtasks,
    String? category,
    int? sortOrder,
  }) {
    return Task(
      id: id,
      title: title ?? this.title, // Fix: fallback to existing title
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  High,
  @HiveField(1)
  Medium,
  @HiveField(2)
  Low
}

@HiveType(typeId: 2)
class Subtask {
  @HiveField(0)
  final String title;
  @HiveField(1)
  bool isCompleted;

  Subtask({required this.title, this.isCompleted = false});
}
