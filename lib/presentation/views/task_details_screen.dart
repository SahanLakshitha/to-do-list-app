import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/task_model.dart';
import '../view_models/task_viewmodel.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late TextEditingController _subtaskController;
  late Task _editedTask;

  @override
  void initState() {
    super.initState();
    _editedTask = widget.task;
    _subtaskController = TextEditingController();
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _editedTask.subtasks.add(Subtask(title: text));
      _subtaskController.clear();
    });
    _saveChanges();
  }

  void _toggleSubtask(int index) {
    setState(() {
      _editedTask.subtasks[index].isCompleted =
          !_editedTask.subtasks[index].isCompleted;
    });
    _saveChanges();
  }

  void _deleteSubtask(int index) {
    setState(() {
      _editedTask.subtasks.removeAt(index);
    });
    _saveChanges();
  }

  Future<void> _saveChanges() async {
    await Provider.of<TaskViewModel>(context, listen: false)
        .updateTask(_editedTask);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editedTask.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Category Chip
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(_editedTask.category),
                backgroundColor: _getCategoryColor(_editedTask.category),
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Date and Priority Row
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 6),
                Text(
                  DateFormat.yMMMd().format(_editedTask.dueDate),
                  style: textTheme.bodyMedium,
                ),
                const Spacer(),
                Icon(Icons.flag, size: 18, color: _getPriorityColor()),
                const SizedBox(width: 6),
                Text(
                  _editedTask.priority.toString().split('.').last,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            if (_editedTask.description?.isNotEmpty ?? false) ...[
              const Text("📝 Description",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                _editedTask.description!,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
            ],

            // Subtasks
            const Text("✅ Subtasks",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_editedTask.subtasks.isEmpty)
              const Text('No subtasks added yet.')
            else
              ..._editedTask.subtasks.asMap().entries.map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Checkbox(
                        value: entry.value.isCompleted,
                        onChanged: (_) => _toggleSubtask(entry.key),
                      ),
                      title: Text(
                        entry.value.title,
                        style: entry.value.isCompleted
                            ? const TextStyle(
                                decoration: TextDecoration.lineThrough)
                            : null,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSubtask(entry.key),
                      ),
                    ),
                  ),

            // Add Subtask Input
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskController,
                    decoration: const InputDecoration(
                      labelText: 'Add subtask',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.subdirectory_arrow_right),
                    ),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addSubtask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.blue;
      case 'Personal':
        return Colors.green;
      case 'Study':
        return Colors.purple;
      case 'Shopping':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor() {
    switch (_editedTask.priority) {
      case Priority.High:
        return Colors.red;
      case Priority.Medium:
        return Colors.amber;
      case Priority.Low:
        return Colors.green;
    }
  }

  void _showEditDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: _editedTask.title);
    final descController = TextEditingController(text: _editedTask.description);
    DateTime? newDueDate = _editedTask.dueDate;
    Priority newPriority = _editedTask.priority;
    String newCategory = _editedTask.category;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Task'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Title cannot be empty' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(newDueDate == null
                      ? 'Select Due Date'
                      : DateFormat.yMMMd().format(newDueDate!)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: newDueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => newDueDate = date);
                    }
                  },
                ),
                DropdownButtonFormField<Priority>(
                  value: newPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: Priority.values
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.toString().split('.').last),
                          ))
                      .toList(),
                  onChanged: (value) => newPriority = value!,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: newCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ['Work', 'Personal', 'Study', 'Shopping']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) => newCategory = value!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _editedTask = _editedTask.copyWith(
                    title: titleController.text,
                    description: descController.text.isEmpty
                        ? null
                        : descController.text,
                    dueDate: newDueDate,
                    priority: newPriority,
                    category: newCategory,
                  );
                });
                _saveChanges();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
