import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/services/theme_controller.dart';

class ThemeSettingsScreen extends StatelessWidget {
  final ThemeController themeController;
  const ThemeSettingsScreen({super.key, required this.themeController});

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await themeController.setThemeMode(
        AppThemeMode.customImage,
        imagePath: pickedFile.path,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallpaper galeri berhasil diterapkan.')),
        );
      }
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
          'PENGATURAN TEMA',
          style: TextStyle(color: Color(0xFFFFFFFF), fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF222222), height: 1.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _ThemeOptionTile(
              title: 'PITCH BLACK (DARK)',
              symbol: '\u25D9',
              isSelected: themeController.currentMode == AppThemeMode.dark,
              onTap: () => themeController.setThemeMode(AppThemeMode.dark),
            ),
            const SizedBox(height: 12),
            _ThemeOptionTile(
              title: 'MINIMALIST WHITE (LIGHT)',
              symbol: '\u2609',
              isSelected: themeController.currentMode == AppThemeMode.light,
              onTap: () => themeController.setThemeMode(AppThemeMode.light),
            ),
            const SizedBox(height: 12),
            _ThemeOptionTile(
              title: 'CUSTOM WALLPAPER (DARI GALERI)',
              symbol: '\u25A3',
              isSelected: themeController.currentMode == AppThemeMode.customImage,
              onTap: () => _pickImageFromGallery(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final String symbol;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.title,
    required this.symbol,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF222222),
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(6.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(symbol, style: const TextStyle(color: Color(0xFF888888), fontSize: 16)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              const Text(
                '[ AKTIF ]',
                style: TextStyle(color: Color(0xFF00FF66), fontFamily: 'monospace', fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }
}
