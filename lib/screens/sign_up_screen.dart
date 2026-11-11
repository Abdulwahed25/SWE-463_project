import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/country.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../utils/phone.dart';
import '../widgets/phone_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  Country _phoneCountry = Country.saudiArabia;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      studentId: _studentIdController.text.trim(),
      phone: toStoredPhone(_phoneCountry, _phoneController.text),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Welcome to Souq.'),
          backgroundColor: SouqColors.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: SouqColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Join the KFUPM Student Market',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: SouqColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create an account to post listings and buy from other students.',
                    style: TextStyle(fontSize: 13, color: SouqColors.subText),
                  ),
                  const SizedBox(height: 20),

                  // Error banner if any
                  if (auth.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: SouqColors.errorBackground,
                        borderRadius: BorderRadius.circular(kSouqRadius),
                        border: Border.all(color: SouqColors.error.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: SouqColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(color: SouqColors.error, fontSize: 13),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: SouqColors.error),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: auth.clearError,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Full Name
                  const Text('Full Name *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Fname Lname',
                      prefixIcon: Icon(Icons.person_outline, color: SouqColors.subText),
                    ),
                    validator: (val) {
                      final text = val?.trim() ?? '';
                      if (text.isEmpty) return 'Please enter your full name.';
                      if (text.length < 3) return 'Name must be at least 3 characters.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Student ID
                  const Text('Student ID *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _studentIdController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 202500123',
                      prefixIcon: Icon(Icons.badge_outlined, color: SouqColors.subText),
                    ),
                    validator: (val) {
                      final text = val?.trim() ?? '';
                      if (text.isEmpty) return 'Please enter your student ID.';
                      if (text.length < 7) return 'Please enter a valid student ID.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Email
                  const Text('Email *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'e.g. name@example.com',
                      prefixIcon: Icon(Icons.email_outlined, color: SouqColors.subText),
                    ),
                    validator: (val) {
                      final text = val?.trim().toLowerCase() ?? '';
                      if (text.isEmpty) return 'Please enter your email.';
                      if (!text.contains('@') || !text.contains('.')) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Phone Number (Optional)
                  const Text('Phone Number (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  PhoneField(
                    controller: _phoneController,
                    country: _phoneCountry,
                    onCountryChanged: (country) => setState(() => _phoneCountry = country),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),

                  // Password
                  const Text('Password *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'At least 6 characters',
                      prefixIcon: const Icon(Icons.lock_outline, color: SouqColors.subText),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: SouqColors.subText,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (val) {
                      final text = val ?? '';
                      if (text.isEmpty) return 'Please enter a password.';
                      if (text.length < 6) return 'Password must be at least 6 characters.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Confirm Password
                  const Text('Confirm Password *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignUp(),
                    decoration: InputDecoration(
                      hintText: 'Re-enter your password',
                      prefixIcon: const Icon(Icons.lock_reset_outlined, color: SouqColors.subText),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: SouqColors.subText,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please confirm your password.';
                      if (val != _passwordController.text) return 'Passwords do not match.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Create Account Button
                  FilledButton(
                    onPressed: auth.isLoading ? null : _handleSignUp,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create account'),
                  ),
                  const SizedBox(height: 16),

                  // Back to Login link
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: SouqColors.subText),
                      ),
                      GestureDetector(
                        onTap: () {
                          auth.clearError();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            color: SouqColors.teal,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
