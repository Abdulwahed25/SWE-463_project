import 'package:flutter/material.dart';

import '../theme.dart';

/// Message shown when a list is empty or something failed
/// (for example: "No chats yet" or "Couldn't load listings").
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFFE2EBED),
              child: Icon(icon, size: 40, color: SouqColors.teal),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SouqColors.text),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: SouqColors.subText),
            ),
            if (buttonText != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(minimumSize: const Size(160, 48)),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
