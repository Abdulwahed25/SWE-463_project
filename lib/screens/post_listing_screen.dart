import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/category.dart';
import '../providers/listings_provider.dart';
import '../theme.dart';

/// Post Listing form. Form fields and the "posting" flag are local (setState).
/// On success the new listing is added to ListingsProvider, so it appears on Home.
class PostListingScreen extends StatefulWidget {
  const PostListingScreen({super.key});

  @override
  State<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends State<PostListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _category;
  String? _condition;
  bool _isPosting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the fields marked in red.')),
      );
      return;
    }
    setState(() => _isPosting = true);
    try {
      final listing = await context.read<ListingsProvider>().addListing(
            title: _titleController.text,
            price: double.parse(_priceController.text.trim()),
            category: _category!,
            condition: _condition!,
            location: _locationController.text,
            description: _descriptionController.text,
          );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.posted, arguments: listing.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't post your listing. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Listing')),
      body: AbsorbPointer(
        absorbing: _isPosting, // block edits while posting
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Photo box. Real photo upload comes with Firebase Storage in Phase 4.
              InkWell(
                borderRadius: BorderRadius.circular(kSouqRadius),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Adding photos will be available in the next version.')),
                ),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: SouqColors.field,
                    borderRadius: BorderRadius.circular(kSouqRadius),
                    border: Border.all(color: SouqColors.border),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: SouqColors.teal, size: 32),
                      SizedBox(height: 6),
                      Text('Add photos (optional)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Calculus textbook'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Title is required';
                  if (text.length < 3) return 'Title must be at least 3 characters';
                  if (text.length > 60) return 'Title must be 60 characters or less';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Price (SAR)', hintText: 'e.g. 50'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Price is required';
                  final price = double.tryParse(text);
                  if (price == null) return 'Enter numbers only';
                  if (price <= 0) return 'Price must be more than 0';
                  if (price > 100000) return 'Price is too high';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [for (final c in kCategories) DropdownMenuItem(value: c, child: Text(c))],
                onChanged: (v) => setState(() => _category = v),
                validator: (v) => v == null ? 'Choose a category' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: [for (final c in kConditions) DropdownMenuItem(value: c, child: Text(c))],
                onChanged: (v) => setState(() => _condition = v),
                validator: (v) => v == null ? 'Choose the condition' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Pickup location', hintText: 'e.g. Building 57'),
                validator: (value) =>
                    (value?.trim() ?? '').isEmpty ? 'Pickup location is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Description is required';
                  if (text.length < 10) return 'Write at least 10 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isPosting ? null : _submit,
                child: _isPosting
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Text('Posting...'),
                        ],
                      )
                    : const Text('Post listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
