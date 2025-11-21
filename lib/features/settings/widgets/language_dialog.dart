import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختر اللغة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.accent),
            title: const Text('العربية'),
            onTap: () => _changeLanguage(context, 'ar'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.accent),
            title: const Text('English'),
            onTap: () => _changeLanguage(context, 'en'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  Future<void> _changeLanguage(BuildContext context, String langCode) async {
    // تطبيق تغيير اللغة
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تغيير اللغة إلى $langCode')),
    );
  }
}