import 'package:isar/isar.dart';

part 'task_model.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String title;

  String? description;

  @Index()
  late DateTime dueDate;

  bool isCompleted = false;

  int priority = 1; // 1: Low, 2: Medium, 3: High

  late DateTime createdAt;
}
