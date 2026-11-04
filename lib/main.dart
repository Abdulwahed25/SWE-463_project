import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import 'providers/listings_provider.dart';
import 'services/listing_repository.dart';
import 'services/local_listing_repository.dart';
import 'theme.dart';

void main() {
  runApp(SouqApp(repository: LocalListingRepository()));
}

class SouqApp extends StatelessWidget {
  const SouqApp({super.key, required this.repository});

  /// Where listings come from. Tests pass a fake repository here.
  final ListingRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListingsProvider(repository)..load()),
      ],
      child: MaterialApp(
        title: 'Souq',
        debugShowCheckedModeBanner: false,
        theme: souqTheme,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
      ),
    );
  }
}
