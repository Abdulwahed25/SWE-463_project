import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/listing.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../utils/iban.dart';

/// Opens a bottom sheet with the seller's IBAN so the buyer can copy it
/// and pay by bank transfer (the "IBAN quick-transfer helper" feature).
Future<void> showSellerPaymentSheet(BuildContext context, Listing listing) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => SellerPaymentSheet(listing: listing),
  );
}

/// Loads the seller's account and shows one of four states:
/// loading, error (with Retry), no IBAN yet (empty), or the IBAN with a Copy button.
class SellerPaymentSheet extends StatefulWidget {
  const SellerPaymentSheet({super.key, required this.listing});

  final Listing listing;

  @override
  State<SellerPaymentSheet> createState() => _SellerPaymentSheetState();
}

class _SellerPaymentSheetState extends State<SellerPaymentSheet> {
  late Future<User?> _sellerFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    // Store the Future so it isn't restarted on every rebuild.
    _sellerFuture = context.read<AuthProvider>().fetchUser(widget.listing.sellerId);
  }

  @override
  Widget build(BuildContext context) {
    // Scrollable so the content never overflows on short screens (or in landscape).
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: FutureBuilder<User?>(
          future: _sellerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _SheetMessage(icon: null, title: 'Loading payment details...', message: '');
            }
            if (snapshot.hasError) {
              return _SheetMessage(
                icon: Icons.wifi_off_outlined,
                title: "Couldn't load payment details",
                message: 'Check your connection and try again.',
                buttonText: 'Retry',
                onPressed: () => setState(_load),
              );
            }
            final seller = snapshot.data;
            if (seller == null || seller.iban.isEmpty) {
              return _SheetMessage(
                icon: Icons.account_balance_outlined,
                title: 'No IBAN yet',
                message:
                    '${widget.listing.sellerName} has not added an IBAN. '
                    'Message the seller to arrange payment.',
              );
            }
            return _IbanDetails(seller: seller);
          },
        ),
      ),
    );
  }
}

class _IbanDetails extends StatelessWidget {
  const _IbanDetails({required this.seller});

  final User seller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Pay by bank transfer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SouqColors.text),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SouqColors.field,
            borderRadius: BorderRadius.circular(kSouqRadius),
            border: Border.all(color: SouqColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Account name', style: TextStyle(fontSize: 12, color: SouqColors.subText)),
              Text(seller.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Text('IBAN', style: TextStyle(fontSize: 12, color: SouqColors.subText)),
              SelectableText(
                formatIban(seller.iban),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Only transfer after you have checked the item with the seller.',
          style: TextStyle(fontSize: 12, color: SouqColors.subText),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.copy_outlined),
          label: const Text('Copy IBAN'),
          onPressed: () {
            final messenger = ScaffoldMessenger.of(context);
            Navigator.pop(context); // close the sheet
            copyIbanToClipboard(messenger, seller.iban);
          },
        ),
      ],
    );
  }
}

/// Icon + title + message used for the loading, error and empty states.
class _SheetMessage extends StatelessWidget {
  const _SheetMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  final IconData? icon; // null shows a loading spinner instead
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        if (icon == null)
          const SizedBox(width: 36, height: 36, child: CircularProgressIndicator())
        else
          Icon(icon, size: 40, color: SouqColors.teal),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SouqColors.text),
        ),
        if (message.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: SouqColors.subText),
          ),
        ],
        if (buttonText != null) ...[
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onPressed, child: Text(buttonText!)),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}
