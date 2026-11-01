import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../features/todos/data/models/task_model.dart';

class AddTaskDialog extends StatefulWidget {
  final Isar isar;
  const AddTaskDialog({super.key, required this.isar});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _selectedPriority = 1;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final newTask = Task()
        ..title = _titleController.text.trim()
        ..description = _descController.text.trim().isNotEmpty 
            ? _descController.text.trim() 
            : null
        ..dueDate = DateTime.now()
        ..priority = _selectedPriority
        ..isCompleted = false
        ..createdAt = DateTime.now();

      await widget.isar.writeTxn(() async {
        await widget.isar.tasks.put(newTask);
      });

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0A0A0A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
        side: const BorderSide(color: Color(0xFF222222), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TAMBAH TASK BARU',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 13),
                cursorColor: const Color(0xFFFFFFFF),
                decoration: _inputDecoration('JUDUL TASK'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul task tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 13),
                cursorColor: const Color(0xFFFFFFFF),
                decoration: _inputDecoration('DESKRIPSI (OPSIONAL)'),
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PRIORITAS:',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 11, fontFamily: 'monospace'),
                  ),
                  DropdownButton<int>(
                    value: _selectedPriority,
                    dropdownColor: const Color(0xFF151515),
                    style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12, fontFamily: 'monospace'),
                    underline: Container(height: 1, color: const Color(0xFF333333)),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('LOW')),
                      DropdownMenuItem(value: 2, child: Text('MEDIUM')),
                      DropdownMenuItem(value: 3, child: Text('HIGH')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPriority = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('BATAL', style: TextStyle(color: Color(0xFF666666), fontSize: 12, fontFamily: 'monospace')),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      foregroundColor: const Color(0xFF000000),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                    ),
                    child: const Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF666666), fontSize: 11, fontFamily: 'monospace'),
      filled: true,
      fillColor: const Color(0xFF151515),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: const BorderSide(color: Color(0xFF333333))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: const BorderSide(color: Color(0xFF333333))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: const BorderSide(color: Color(0xFFFFFFFF))),
    );
  }
}
