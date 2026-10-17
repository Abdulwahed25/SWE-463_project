import 'package:flutter/material.dart';

import '../theme.dart';

/// One button on a placeholder page.
class PlaceholderAction {
  const PlaceholderAction(this.label, this.onPressed, {this.primary = false});

  final String label;
  final VoidCallback onPressed;
  final bool primary;
}

/// Simple page used by the Phase 2 starter screens:
/// an icon, a title, a short text and buttons to move to other screens.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String message;
  final List<PlaceholderAction> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFE2EBED),
              child: Icon(icon, size: 36, color: SouqColors.teal),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            for (final action in actions) ...[
              SizedBox(
                width: double.infinity,
                child: action.primary
                    ? FilledButton(onPressed: action.onPressed, child: Text(action.label))
                    : OutlinedButton(onPressed: action.onPressed, child: Text(action.label)),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
