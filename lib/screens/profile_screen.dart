import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out of Souq?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: SouqColors.background,
        appBar: AppBar(title: const Text('Profile')),
        body: _buildGuestProfile(context),
      );
    }

    final user = auth.user;
    final displayName = user?.name.isNotEmpty == true ? user!.name : 'KFUPM Student';
    final email = user?.email.isNotEmpty == true ? user!.email : 'Not logged in';
    final studentId = user?.studentId.isNotEmpty == true ? user!.studentId : '—';
    final phone = user?.phone.isNotEmpty == true ? user!.phone : 'Not provided';
    final iban = user?.iban.isNotEmpty == true ? user!.iban : 'Not provided';

    return Scaffold(
      backgroundColor: SouqColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(kSouqRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: SouqColors.teal.withValues(alpha: 0.12),
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: SouqColors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: SouqColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: SouqColors.subText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Profile Details Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(kSouqRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.badge_outlined,
                    label: 'Student ID',
                    value: studentId,
                  ),
                  const Divider(height: 1, indent: 56),
                  _InfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Phone Number',
                    value: phone,
                  ),
                  const Divider(height: 1, indent: 56),
                  _InfoTile(
                    icon: Icons.account_balance_outlined,
                    label: 'Bank IBAN',
                    value: iban,
                    trailing: user?.iban.isNotEmpty == true
                        ? IconButton(
                            icon: const Icon(Icons.copy_outlined, size: 18, color: SouqColors.teal),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: user!.iban));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('IBAN copied to clipboard')),
                              );
                            },
                          )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Quick Actions Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(kSouqRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined, color: SouqColors.teal),
                    title: const Text('Edit Profile & IBAN', style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: SouqColors.hint),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.list_alt_outlined, color: SouqColors.teal),
                    title: const Text('My Listings', style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: SouqColors.hint),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.myListings),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Log Out Button
            OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: SouqColors.error),
              label: const Text('Log out', style: TextStyle(color: SouqColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: SouqColors.error),
                backgroundColor: Colors.white,
              ),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildGuestProfile(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SouqColors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 44,
                color: SouqColors.teal,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Guest Account',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: SouqColors.text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You are browsing Souq as a guest. Create an account or log in to unlock all features.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: SouqColors.subText),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(kSouqRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  _FeatureRow(icon: Icons.add_box_outlined, text: 'Post listings to sell items'),
                  SizedBox(height: 12),
                  _FeatureRow(icon: Icons.chat_bubble_outline, text: 'Chat and message sellers directly'),
                  SizedBox(height: 12),
                  _FeatureRow(icon: Icons.favorite_border, text: 'Save items to your wishlist'),
                  SizedBox(height: 12),
                  _FeatureRow(icon: Icons.account_balance_outlined, text: 'Receive payments with your IBAN'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              icon: const Icon(Icons.login),
              label: const Text('Log in / Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: SouqColors.teal),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: SouqColors.text),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: SouqColors.subText),
      title: Text(label, style: const TextStyle(fontSize: 12, color: SouqColors.subText)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SouqColors.text),
      ),
      trailing: trailing,
    );
  }
}
