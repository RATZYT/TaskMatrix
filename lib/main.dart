import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'features/habits/data/models/habit_model.dart';
import 'features/todos/data/models/task_model.dart';
import 'app/services/notification_service.dart';
import 'app/services/theme_controller.dart';
import 'main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService.init();
  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [TaskSchema, HabitSchema],
    directory: dir.path,
  );

  final themeController = ThemeController();
  await themeController.loadPreferences();

  runApp(MyApp(isar: isar, themeController: themeController));
}

class MyApp extends StatelessWidget {
  final Isar isar;
  final ThemeController themeController;

  const MyApp({super.key, required this.isar, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'To-Do & Habit Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: MainNavigation(isar: isar, themeController: themeController),
        );
      },
    );
  }
}
