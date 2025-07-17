import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/services/notification_service.dart';
import 'data/models/task_model.dart';
import 'data/repositories/task_repository.dart';
import 'presentation/view_models/task_viewmodel.dart';
import 'presentation/views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(SubtaskAdapter());
  await Hive.openBox<Task>('tasks');
  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // create: (_) => TaskViewModel(TaskRepository(Hive.box('tasks'))),
          create: (context) {
            final viewModel = TaskViewModel(TaskRepository(Hive.box('tasks')));
            viewModel.loadTasks();
            return viewModel;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}
