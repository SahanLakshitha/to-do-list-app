import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/presentation/view_models/task_viewmodel.dart';
import 'package:task_manager_app/presentation/views/add_task_screen.dart';
import '/data/models/task_model.dart';
import 'task_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Ensure loadTasks runs only once after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        Provider.of<TaskViewModel>(context, listen: false).loadTasks();
        _isInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<TaskViewModel>(context);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
        appBar: AppBar(
          title: const Text('To-Do List'),
          backgroundColor: const Color.fromARGB(255, 212, 241, 255),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showCategoryFilter(context),
            ),
          ],
        ),
        body: Container(
          color: const Color.fromARGB(255, 212, 241, 255),
          child: Consumer<TaskViewModel>(
            builder: (context, vm, child) {
              if (vm.tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('lib/assets/dog.png',
                          height: 150, fit: BoxFit.contain),
                      // const SizedBox(height: 16),
                      Text(
                        'No tasks yet!',
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add your first task',
                        style: textTheme.titleSmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) newIndex--;
                  vm.reorderTasks(oldIndex, newIndex);
                },
                itemCount: vm.tasks.length,
                itemBuilder: (ctx, index) {
                  final task = vm.tasks[index];
                  return Dismissible(
                    key: Key(task.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 248, 5, 5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.delete_outline,
                              color: Color.fromARGB(255, 255, 255, 255)),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    confirmDismiss: (_) => _showDeleteConfirmation(context),
                    onDismissed: (_) => vm.deleteTask(task.id),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) => vm.updateTask(
                            task.copyWith(isCompleted: !task.isCompleted),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: textTheme.bodyLarge?.copyWith(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          '${task.category} • ${DateFormat('MMM d, y – h:mm a').format(task.dueDate)}',
                          style: textTheme.bodySmall,
                        ),
                        trailing: Icon(
                          _getPriorityIcon(task.priority),
                          color: _getPriorityColor(task.priority, colors),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailsScreen(task: task),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTaskScreen()),
          ),
          child: const Icon(Icons.add),
        ));
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return (await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color.fromARGB(255, 248, 5, 5)),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _showCategoryFilter(BuildContext context) {
    final vm = Provider.of<TaskViewModel>(context, listen: false);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surfaceContainerHighest,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => AnimatedPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        duration: const Duration(milliseconds: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Filter by Category',
                style: textTheme.titleLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children:
                    ['Work', 'Personal', 'Study', 'Shopping'].map((category) {
                  final isSelected = vm.currentFilter == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) {
                        vm.filterByCategory(isSelected ? null : category);
                        Navigator.pop(ctx);
                      },
                      backgroundColor: colors.surfaceContainerHighest,
                      selectedColor: colors.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: isSelected
                              ? colors.primary
                              : colors.outline.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FilledButton.tonal(
                onPressed: () {
                  vm.filterByCategory(null);
                  Navigator.pop(ctx);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHighest,
                  foregroundColor: colors.error,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: colors.error.withOpacity(0.2)),
                  ),
                ),
                child: const Text('Clear Filters'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.High:
        return Icons.flag;
      case Priority.Medium:
        return Icons.flag_outlined;
      case Priority.Low:
        return Icons.outlined_flag;
    }
  }

  Color _getPriorityColor(Priority priority, ColorScheme colors) {
    switch (priority) {
      case Priority.High:
        return colors.error;
      case Priority.Medium:
        return colors.primary;
      case Priority.Low:
        return colors.secondary;
    }
  }
}
