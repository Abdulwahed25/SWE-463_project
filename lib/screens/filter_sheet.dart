import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/listings_provider.dart';

/// Bottom sheet opened from the filter button on Home.
/// The choices are kept in local state (setState) until "Show results" is pressed.
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  final _formKey = GlobalKey<FormState>();
  final _maxPriceController = TextEditingController();
  String? _category;
  bool _availableOnly = false;

  @override
  void initState() {
    super.initState();
    final current = context.read<ListingsProvider>().filter;
    _category = current.category;
    _availableOnly = current.availableOnly;
    if (current.maxPrice != null) {
      _maxPriceController.text = current.maxPrice!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _maxPriceController.dispose();
    super.dispose();
  }

  void _apply() {
    if (!_formKey.currentState!.validate()) return;
    final text = _maxPriceController.text.trim();
    context.read<ListingsProvider>().setFilter(ListingFilter(
          category: _category,
          maxPrice: text.isEmpty ? null : double.parse(text),
          availableOnly: _availableOnly,
        ));
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _category = null;
      _availableOnly = false;
      _maxPriceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(onPressed: _reset, child: const Text('Reset')),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                for (final c in kCategories)
                  ChoiceChip(
                    label: Text(c),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Max price (SAR)', hintText: 'No limit'),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return null;
                final number = double.tryParse(text);
                if (number == null || number <= 0) return 'Enter a number above 0';
                return null;
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Available only'),
              value: _availableOnly,
              onChanged: (v) => setState(() => _availableOnly = v),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _apply, child: const Text('Show results')),
            ),
          ],
        ),
      ),
    );
  }
}
