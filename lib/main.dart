import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/listings_provider.dart';
import 'services/auth_repository.dart';
import 'services/chat_repository.dart';
import 'services/firebase_auth_repository.dart';
import 'services/firestore_chat_repository.dart';
import 'services/firestore_listing_repository.dart';
import 'services/listing_repository.dart';
import 'theme.dart';

Future<void> main() async {
  // Needed before calling Firebase, because main() is async.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    SouqApp(
      repository: FirestoreListingRepository(),
      authRepository: FirebaseAuthRepository(),
      chatRepository: FirestoreChatRepository(),
    ),
  );
}

class SouqApp extends StatelessWidget {
  const SouqApp({
    super.key,
    required this.repository,
    required this.authRepository,
    required this.chatRepository,
  });

  /// Data sources. The app passes the Firebase versions; tests pass fakes.
  final ListingRepository repository;
  final AuthRepository authRepository;
  final ChatRepository chatRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository)..loadSession(),
        ),
        // Listings and chats follow the signed-in user: when AuthProvider
        // changes (login, sign up, logout), update() passes them the new user.
        ChangeNotifierProxyProvider<AuthProvider, ListingsProvider>(
          create: (_) => ListingsProvider(repository)..load(),
          update: (_, auth, listings) => listings!..setUser(auth.user?.id),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(chatRepository),
          update: (_, auth, chat) => chat!..setUser(auth.user),
        ),
      ],
      child: MaterialApp(
        title: 'Souq',
        debugShowCheckedModeBanner: false,
        theme: souqTheme,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
        builder: (context, child) {
          // On wide screens (web, tablets) the app is shown as a phone-width column.
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
