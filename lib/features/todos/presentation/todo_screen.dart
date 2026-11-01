import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../data/models/task_model.dart';
import '../../../widgets/add_task_dialog.dart';

class TodoScreen extends StatelessWidget {
  final Isar isar;
  const TodoScreen({super.key, required this.isar});

  Future<void> _toggleTaskCompletion(Task task) async {
    await isar.writeTxn(() async {
      task.isCompleted = !task.isCompleted;
      await isar.tasks.put(task);
    });
  }

  Future<void> _deleteTask(Id id) async {
    await isar.writeTxn(() async {
      await isar.tasks.delete(id);
    });
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 3:
        return 'HIGH';
      case 2:
        return 'MEDIUM';
      default:
        return 'LOW';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text(
          'TO-DO LIST',
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
      body: StreamBuilder<List<Task>>(
        stream: isar.tasks.watchSteady(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'BELUM ADA TASK. TAMBAHKAN SEKARANG.',
                style: TextStyle(color: Color(0xFF555555), fontFamily: 'monospace', fontSize: 12),
              ),
            );
          }

          final tasks = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = tasks[index];
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
                              const Text('\u25A0 ', style: TextStyle(color: Color(0xFF666666), fontSize: 10)),
                              Text(
                                'PRIORITY: \${_getPriorityLabel(task.priority)}',
                                style: const TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 10,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            task.title,
                            style: TextStyle(
                              color: task.isCompleted ? const Color(0xFF555555) : const Color(0xFFFFFFFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (task.description != null && task.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description!,
                              style: const TextStyle(
                                color: Color(0xFF777777),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Text('\u00D7', style: TextStyle(color: Color(0xFF555555), fontSize: 18, fontWeight: FontWeight.bold)),
                          onPressed: () => _deleteTask(task.id),
                          tooltip: 'Hapus Task',
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _toggleTaskCompletion(task),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: task.isCompleted ? const Color(0xFFFFFFFF) : Colors.transparent,
                              border: Border.all(
                                color: task.isCompleted ? const Color(0xFFFFFFFF) : const Color(0xFF444444),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: task.isCompleted
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
            builder: (context) => AddTaskDialog(isar: isar),
          );
        },
      ),
    );
  }
}
