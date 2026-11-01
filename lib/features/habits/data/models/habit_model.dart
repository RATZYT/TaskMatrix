import 'package:isar/isar.dart';

part 'habit_model.g.dart';

@collection
class Habit {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  String? category;

  List<DateTime> completedDates = [];

  int currentStreak = 0;
  int bestStreak = 0;

  int reminderHour = 7;
  int reminderMinute = 0;

  late DateTime createdAt;
}
