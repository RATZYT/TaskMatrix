import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../features/habits/data/models/habit_model.dart';
import '../app/services/notification_service.dart';

class AddHabitDialog extends StatefulWidget {
  final Isar isar;
  const AddHabitDialog({super.key, required this.isar});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  
  int _selectedHour = 7;
  int _selectedMinute = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
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
      setState(() {
        _selectedHour = picked.hour;
        _selectedMinute = picked.minute;
      });
    }
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final newHabit = Habit()
        ..name = _nameController.text.trim()
        ..category = _categoryController.text.trim().isNotEmpty 
            ? _categoryController.text.trim().toUpperCase() 
            : 'GENERAL'
        ..reminderHour = _selectedHour
        ..reminderMinute = _selectedMinute
        ..createdAt = DateTime.now();

      await widget.isar.writeTxn(() async {
        await widget.isar.habits.put(newHabit);
      });

      await NotificationService.scheduleDailyHabitReminder(
        id: newHabit.id,
        title: newHabit.name,
        hour: _selectedHour,
        minute: _selectedMinute,
      );

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
                'TAMBAH HABIT BARU',
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
                controller: _nameController,
                style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 13),
                cursorColor: const Color(0xFFFFFFFF),
                decoration: _inputDecoration('NAMA HABIT (Cth: Workout, Ngoding)'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama habit tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _categoryController,
                style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 13),
                cursorColor: const Color(0xFFFFFFFF),
                decoration: _inputDecoration('KATEGORI (Cth: HEALTH, DEV)'),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'WAKTU ALARM:',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 11, fontFamily: 'monospace'),
                  ),
                  TextButton(
                    onPressed: () => _selectTime(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF151515),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        side: const BorderSide(color: Color(0xFF333333)),
                      ),
                    ),
                    child: Text(
                      '${_selectedHour.toString().padLeft(2, '0')}: ${_selectedMinute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Color(0xFF00FF66), fontFamily: 'monospace', fontSize: 12),
                    ),
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
                    onPressed: _saveHabit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      foregroundColor: const Color(0xFF000000),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: Color(0xFF333333)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: Color(0xFF333333)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: Color(0xFFFFFFFF)),
      ),
    );
  }
}
