import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../data/models/habit_model.dart';
import '../../../app/services/notification_service.dart';
import '../../../widgets/add_habit_dialog.dart';

class HabitScreen extends StatefulWidget {
  final Isar isar;
  const HabitScreen({super.key, required this.isar});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  Future<void> _toggleHabit(Habit habit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await widget.isar.writeTxn(() async {
      final index = habit.completedDates.indexWhere((d) =>
          d.year == today.year && d.month == today.month && d.day == today.day);

      if (index >= 0) {
        habit.completedDates.removeAt(index);
      } else {
        habit.completedDates.add(today);
        habit.completedDates.sort((a, b) => a.compareTo(b));
      }

      _updateStreak(habit, today);
      await widget.isar.habits.put(habit);
    });
  }

  void _updateStreak(Habit habit, DateTime today) {
    if (habit.completedDates.isEmpty) {
      habit.currentStreak = 0;
      return;
    }
    int streak = 0;
    DateTime checkDate = today;
    while (true) {
      bool found = habit.completedDates.any((d) =>
          d.year == checkDate.year &&
          d.month == checkDate.month &&
          d.day == checkDate.day);
      if (found) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    habit.currentStreak = streak;
    if (streak > habit.bestStreak) habit.bestStreak = streak;
  }

  Future<void> _pickAlarmTime(Habit habit) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: habit.reminderHour, minute: habit.reminderMinute),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFFFFF),
              onPrimary: Color(0xFF000000),
              surface: Color(0xFF0A0A0A),
              onSurface: Color(0xFFFFFFFF),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await widget.isar.writeTxn(() async {
        habit.reminderHour = picked.hour;
        habit.reminderMinute = picked.minute;
        await widget.isar.habits.put(habit);
      });

      await NotificationService.scheduleDailyHabitReminder(
        id: habit.id,
        title: habit.name,
        hour: picked.hour,
        minute: picked.minute,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alarm diset ke ${picked.format(context)}'),
            backgroundColor: const Color(0xFF222222),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text(
          'HABIT TRACKER',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF222222), height: 1.0),
        ),
      ),
      body: StreamBuilder<List<Habit>>(
        stream: widget.isar.habits.watchSteady(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'BELUM ADA HABIT. TAMBAHKAN SEKARANG.',
                style: TextStyle(color: Color(0xFF555555), fontFamily: 'monospace', fontSize: 12),
              ),
            );
          }

          final habits = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: habits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final habit = habits[index];
              final isCompletedToday = habit.completedDates.any((d) =>
                  d.year == todayDate.year &&
                  d.month == todayDate.month &&
                  d.day == todayDate.day);

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  border: Border.all(color: const Color(0xFF222222), width: 1.0),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('\u25C9 ', style: TextStyle(color: Color(0xFF666666), fontSize: 12)),
                              Text(
                                (habit.category ?? 'GENERAL').toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 10,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            habit.name,
                            style: TextStyle(
                              color: isCompletedToday ? const Color(0xFF555555) : const Color(0xFFFFFFFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration: isCompletedToday ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('\u25B2 ', style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 10)),
                              Text(
                                'STREAK:  ${habit.currentStreak} HARI',
                                style: const TextStyle(color: Color(0xFF888888), fontSize: 11, fontFamily: 'monospace'),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () => _pickAlarmTime(habit),
                                child: Text(
                                  'ALARM:  ${habit.reminderHour.toString().padLeft(2, '0')}: ${habit.reminderMinute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Color(0xFF00FF66), fontSize: 11, fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _toggleHabit(habit),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCompletedToday ? const Color(0xFFFFFFFF) : Colors.transparent,
                          border: Border.all(
                            color: isCompletedToday ? const Color(0xFFFFFFFF) : const Color(0xFF444444),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: isCompletedToday
                            ? const Center(
                                child: Text(
                                  '\u2713',
                                  style: TextStyle(color: Color(0xFF000000), fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFFFFF),
        child: const Text('+', style: TextStyle(color: Color(0xFF000000), fontSize: 20, fontWeight: FontWeight.bold)),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddHabitDialog(isar: widget.isar),
          );
        },
      ),
    );
  }
}
