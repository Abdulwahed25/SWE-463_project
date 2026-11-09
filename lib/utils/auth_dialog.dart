import 'package:flutter/material.dart';

import '../app_routes.dart';

/// Shows a dialog prompting a guest user to log in to perform a restricted action.
void showLoginPrompt(
  BuildContext context, {
  String title = 'Login Required',
  required String message,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.pushNamed(context, AppRoutes.login);
          },
          child: const Text('Log in'),
        ),
      ],
    ),
  );
}
