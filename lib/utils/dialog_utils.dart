import 'package:flutter/material.dart';

class DialogUtils {
  static Future<bool> showConfirmDelete(
    BuildContext context, {
    String title = 'Επιβεβαίωση διαγραφής',
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Άκυρο'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Διαγραφή'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
