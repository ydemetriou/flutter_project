import 'package:flutter/material.dart';

class DialogUtils {
  static void showConfirmDelete(
    BuildContext context, {
    String message = 'Θέλεις σίγουρα να διαγράψεις;',
    required VoidCallback onConfirm,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Διαγραφή',
          onPressed: onConfirm,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
