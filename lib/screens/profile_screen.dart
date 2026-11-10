import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../theme.dart';
import '../utils/iban.dart';
import '../utils/phone.dart';
import '../widgets/section_card.dart';

/// Profile tab: the signed-in student's details, their activity on Souq,
/// and links to Edit Profile and My Listings. Guests see a sign-in prompt.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out of Souq?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
    // watch = rebuild this screen whenever the user changes (e.g. after Edit Profile)
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    Widget body;
    if (user == null && auth.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (user == null) {
      body = const _GuestProfile();
    } else {
      body = _UserProfile(user: user, onLogout: () => _confirmLogout(context));
    }

    return Scaffold(
      backgroundColor: SouqColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: body,
    );
  }
}

class _UserProfile extends StatelessWidget {
  const _UserProfile({required this.user, required this.onLogout});

  final User user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final hasIban = user.iban.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: 18),
          const _ActivityStats(),
          const SizedBox(height: 18),

          // Account details
          SectionCard(
            child: Column(
              children: [
                _InfoTile(icon: Icons.badge_outlined, label: 'Student ID', value: user.studentId),
                const Divider(height: 1, indent: 56),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: user.phone.isEmpty ? 'Not provided' : formatPhoneForDisplay(user.phone),
                ),
                const Divider(height: 1, indent: 56),
                if (hasIban)
                  _InfoTile(
                    icon: Icons.account_balance_outlined,
                    label: 'Bank IBAN',
                    value: formatIban(user.iban),
                    trailing: IconButton(
                      tooltip: 'Copy IBAN',
                      icon: const Icon(Icons.copy_outlined, size: 18, color: SouqColors.teal),
                      onPressed: () => copyIbanToClipboard(ScaffoldMessenger.of(context), user.iban),
                    ),
                  )
                else
                  // No IBAN yet: remind the seller, buyers need it to pay them
                  ListTile(
                    leading: const Icon(Icons.account_balance_outlined, color: SouqColors.error),
                    title: const Text(
                      'Add your IBAN',
                      style: TextStyle(fontWeight: FontWeight.w600, color: SouqColors.text),
                    ),
                    subtitle: const Text('Buyers need it to pay you by bank transfer.'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: SouqColors.hint),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Quick actions
          SectionCard(
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile & IBAN',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                ),
                const Divider(height: 1, indent: 56),
                _ActionTile(
                  icon: Icons.list_alt_outlined,
                  title: 'My Listings',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.myListings),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            icon: const Icon(Icons.logout, color: SouqColors.error),
            label: const Text('Log out', style: TextStyle(color: SouqColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: SouqColors.error),
              backgroundColor: Colors.white,
            ),
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}

/// Avatar with the user's initials, name and email.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  /// "Ayman Musalli" -> "AM", "Ayman" -> "A".
  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: SouqColors.teal.withValues(alpha: 0.12),
            child: Text(
              initials(user.name),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: SouqColors.teal),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SouqColors.text),
          ),
          const SizedBox(height: 4),
          Text(user.email, style: const TextStyle(fontSize: 14, color: SouqColors.subText)),
        ],
      ),
    );
  }
}

/// Posted / Sold / Saved counts. They come from the shared ListingsProvider,
/// so they update right away when the user posts, marks as sold, or saves.
class _ActivityStats extends StatelessWidget {
  const _ActivityStats();

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>();
    final mine = listings.myListings;
    final sold = mine.where((l) => l.isSold).length;
    final loading = listings.isLoading;

    String show(int n) => loading ? '–' : '$n';

    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          _StatItem(value: show(mine.length), label: 'Posted'),
          const _StatDivider(),
          _StatItem(value: show(sold), label: 'Sold'),
          const _StatDivider(),
          _StatItem(value: show(listings.favorites.length), label: 'Saved'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SouqColors.teal),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: SouqColors.subText)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: SouqColors.border);
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: SouqColors.teal),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: SouqColors.hint),
      onTap: onTap,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value, this.trailing});

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

/// Shown on the Profile tab when browsing as a guest.
class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: SouqColors.teal.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.person_outline, size: 44, color: SouqColors.teal),
            ),
            const SizedBox(height: 18),
            const Text(
              'Guest Account',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: SouqColors.text),
            ),
            const SizedBox(height: 8),
            const Text(
              'You are browsing Souq as a guest. Create an account or log in to unlock all features.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: SouqColors.subText),
            ),
            const SizedBox(height: 24),
            const SectionCard(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
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
          child: Text(text, style: const TextStyle(fontSize: 13, color: SouqColors.text)),
        ),
      ],
    );
  }
}
