import 'package:flutter/material.dart';

import '../widgets/placeholder_page.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: PlaceholderPage(
        icon: Icons.edit_outlined,
        title: 'Edit profile',
        message: 'Students change their photo, name, phone number and IBAN here.',
        actions: [
          PlaceholderAction('Save changes', () => Navigator.pop(context), primary: true),
        ],
      ),
    );
  }
}
