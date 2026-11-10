import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/listings_provider.dart';
import 'services/auth_repository.dart';
import 'services/chat_repository.dart';
import 'services/listing_repository.dart';
import 'services/local_auth_repository.dart';
import 'services/local_chat_repository.dart';
import 'services/local_listing_repository.dart';
import 'theme.dart';

void main() {
  runApp(SouqApp(
    repository: LocalListingRepository(),
    authRepository: LocalAuthRepository(),
    chatRepository: LocalChatRepository(),
  ));
}

class SouqApp extends StatelessWidget {
  const SouqApp({
    super.key,
    required this.repository,
    this.authRepository,
    this.chatRepository,
  });

  /// Where listings come from. Tests pass a fake repository here.
  final ListingRepository repository;

  /// Authentication data source.
  final AuthRepository? authRepository;

  /// Chat data source (added for messaging feature).
  final ChatRepository? chatRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository ?? LocalAuthRepository())..loadSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => ListingsProvider(repository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(chatRepository ?? LocalChatRepository())..loadChats(),
        ),
      ],
      child: MaterialApp(
        title: 'Souq',
        debugShowCheckedModeBanner: false,
        theme: souqTheme,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
        builder: (context, child) {
          return Container(
            color: const Color(0xFFE2E8F0),
            alignment: Alignment.center,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipRect(child: child ?? const SizedBox.shrink()),
            ),
          );
        },
      ),
    );
  }
}