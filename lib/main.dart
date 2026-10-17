import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'theme.dart';

void main() {
  runApp(const SouqApp());
}

class SouqApp extends StatelessWidget {
  const SouqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Souq',
      debugShowCheckedModeBanner: false,
      theme: souqTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
