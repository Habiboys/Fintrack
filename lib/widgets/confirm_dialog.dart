import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final Color cancelColor;
  final Function onConfirm;

  const ConfirmDialog({
    super.key,
    this.title = 'Konfirmasi',
    required this.content,
    this.confirmText = 'Hapus',
    this.cancelText = 'Batal',
    this.confirmColor = Colors.red,
    this.cancelColor = Colors.grey,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(content),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: cancelColor),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelText),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }

  // Helper method to show dialog
  static Future<void> show({
    required BuildContext context,
    String title = 'Konfirmasi',
    required String content,
    String confirmText = 'Hapus',
    String cancelText = 'Batal',
    Color confirmColor = Colors.red,
    Color cancelColor = Colors.grey,
    required Function onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder:
          (context) => ConfirmDialog(
            title: title,
            content: content,
            confirmText: confirmText,
            cancelText: cancelText,
            confirmColor: confirmColor,
            cancelColor: cancelColor,
            onConfirm: onConfirm,
          ),
    );
  }
}
