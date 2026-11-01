import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'features/habits/presentation/habit_screen.dart';
import 'features/todos/presentation/todo_screen.dart';
import 'features/settings/presentation/theme_settings_screen.dart';
import 'app/services/theme_controller.dart';

class MainNavigation extends StatefulWidget {
  final Isar isar;
  final ThemeController themeController;

  const MainNavigation({super.key, required this.isar, required this.themeController});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HabitScreen(isar: widget.isar),
      TodoScreen(isar: widget.isar),
      ThemeSettingsScreen(themeController: widget.themeController),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A),
          border: Border(top: BorderSide(color: Color(0xFF222222), width: 1.0)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF0A0A0A),
          selectedItemColor: const Color(0xFFFFFFFF),
          unselectedItemColor: const Color(0xFF555555),
          selectedLabelStyle: const TextStyle(fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontFamily: 'monospace', fontSize: 9),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Text('\u25C9', style: TextStyle(fontSize: 14)), label: 'HABITS'),
            BottomNavigationBarItem(icon: Text('\u25A0', style: TextStyle(fontSize: 14)), label: 'TO-DO'),
            BottomNavigationBarItem(icon: Text('\u25A3', style: TextStyle(fontSize: 14)), label: 'THEME'),
          ],
        ),
      ),
    );
  }
}
