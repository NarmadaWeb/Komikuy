import 'package:flutter/material.dart';

class AppAlerts {
  static Future<void> showSuccess(BuildContext context, String message, {String title = 'Success'}) {
    return showDialog(
      context: context,
      builder: (context) => _CustomDialog(
        title: title,
        message: message,
        icon: Icons.check_circle_outline,
        color: Colors.green,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static Future<void> showError(BuildContext context, String message, {String title = 'Error'}) {
    return showDialog(
      context: context,
      builder: (context) => _CustomDialog(
        title: title,
        message: message,
        icon: Icons.error_outline,
        color: Colors.red,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirm(BuildContext context, String message, {String title = 'Confirm', required VoidCallback onConfirm}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => _CustomDialog(
        title: title,
        message: message,
        icon: Icons.help_outline,
        color: Theme.of(context).primaryColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final List<Widget> actions;

  const _CustomDialog({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
