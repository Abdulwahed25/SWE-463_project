import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/country.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../utils/iban.dart';
import '../utils/phone.dart';
import '../utils/profile_validators.dart';
import '../widgets/empty_state.dart';
import '../widgets/iban_field.dart';
import '../widgets/phone_field.dart';

/// Lets the signed-in student change their name, phone number and IBAN.
///
/// State ownership:
/// - Form fields, "saving" and "tried to save" flags are local to this screen (setState).
/// - The saved user lives in the shared AuthProvider, so Profile (and every other
///   screen that watches it) refreshes as soon as the save succeeds.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ibanController = TextEditingController();
  Country _phoneCountry = Country.saudiArabia;

  /// The user as it was when the screen opened (to detect unsaved changes).
  User? _original;
  bool _isSaving = false;
  bool _triedToSave = false; // show errors while typing only after the first Save press

  @override
  void initState() {
    super.initState();
    _original = context.read<AuthProvider>().user;
    final user = _original;
    if (user != null) {
      _nameController.text = user.name;
      // "+966530344226" -> country Saudi Arabia + "53-034-4226"
      final phone = parsePhone(user.phone);
      _phoneCountry = phone.country;
      _phoneController.text = formatLocalPhone(phone.country, phone.digits);
      _ibanController.text = IbanField.toFieldText(user.iban);
    }
    // Rebuild when any field changes so the Save button enables/disables.
    for (final c in [_nameController, _phoneController, _ibanController]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  /// The values the user typed, cleaned up the way we save them.
  User? _buildUpdatedUser() {
    return _original?.copyWith(
      name: _nameController.text.trim(),
      phone: toStoredPhone(_phoneCountry, _phoneController.text),
      iban: IbanField.toStoredIban(_ibanController.text),
    );
  }

  bool get _hasChanges {
    final original = _original;
    final updated = _buildUpdatedUser();
    if (original == null || updated == null) return false;
    return updated.name != original.name.trim() ||
        updated.phone != normalizePhone(original.phone) ||
        updated.iban != normalizeIban(original.iban);
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    setState(() => _triedToSave = true);
    if (!_formKey.currentState!.validate()) return;

    final updated = _buildUpdatedUser();
    if (updated == null) return;

    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSaving = true);
    final success = await auth.updateProfile(updated);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: SouqColors.green),
      );
      navigator.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Failed to update profile. Try again.'),
          backgroundColor: SouqColors.error,
        ),
      );
    }
  }

  /// Asks before leaving the screen with unsaved changes.
  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your changes to your profile have not been saved.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep editing')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: SouqColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = _original;
    if (user == null) {
      // Should not happen (Profile only links here when logged in), but never show a blank screen.
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const EmptyState(
          icon: Icons.person_off_outlined,
          title: 'Not logged in',
          message: 'Log in to edit your profile.',
        ),
      );
    }

    final hasChanges = _hasChanges;

    // PopScope blocks the back button / back gesture while there are unsaved
    // changes and asks the user first.
    return PopScope(
      canPop: !hasChanges || _isSaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: SouqColors.background,
        appBar: AppBar(title: const Text('Edit Profile')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidateMode: _triedToSave ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Read-only account info
                const _Label('Email'),
                _ReadOnlyField(value: user.email, icon: Icons.email_outlined),
                const SizedBox(height: 16),
                const _Label('Student ID'),
                _ReadOnlyField(value: user.studentId, icon: Icons.badge_outlined),
                const SizedBox(height: 6),
                const Text(
                  'Email and student ID are linked to your account and cannot be changed.',
                  style: TextStyle(fontSize: 12, color: SouqColors.subText),
                ),
                const Divider(height: 32),

                const _Label('Full Name *'),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person_outline, color: SouqColors.subText),
                  ),
                  validator: ProfileValidators.name,
                ),
                const SizedBox(height: 16),

                const _Label('Phone Number'),
                PhoneField(
                  controller: _phoneController,
                  country: _phoneCountry,
                  onCountryChanged: (country) => setState(() => _phoneCountry = country),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                const _Label('Bank IBAN (optional)'),
                const Text(
                  'Buyers can copy your IBAN from your listings to pay you by bank transfer.',
                  style: TextStyle(fontSize: 12, color: SouqColors.subText),
                ),
                const SizedBox(height: 6),
                IbanField(controller: _ibanController),
                const SizedBox(height: 28),

                FilledButton(
                  // Disabled while saving, and when nothing was changed.
                  onPressed: _isSaving || !hasChanges ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Save changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

/// A greyed-out field with a lock icon for values the user cannot edit.
class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.value, required this.icon});

  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      style: const TextStyle(color: SouqColors.subText),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: SouqColors.hint),
        suffixIcon: const Icon(Icons.lock_outline, size: 18, color: SouqColors.hint),
      ),
    );
  }
}
