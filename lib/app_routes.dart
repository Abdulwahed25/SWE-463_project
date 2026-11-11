import 'package:flutter/material.dart';

import 'screens/chat_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/listing_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/messages_screen.dart';
import 'screens/my_listings_screen.dart';
import 'screens/post_listing_screen.dart';
import 'screens/posted_screen.dart';
import 'screens/sign_up_screen.dart';

/// All route names in one place, so screens never type paths by hand.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String home = '/home'; // main shell with the bottom bar
  static const String listingDetail = '/listing';
  static const String messages = '/messages';
  static const String chat = '/chat';
  static const String postListing = '/post';
  static const String posted = '/posted';
  static const String editProfile = '/edit-profile';
  static const String myListings = '/my-listings';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        signUp: (_) => const SignUpScreen(),
        home: (_) => const MainShell(),
        listingDetail: (_) => const ListingDetailScreen(),
        messages: (_) => const MessagesScreen(),
        chat: (context) {
          // Arguments come from "Message seller" or from the Messages tab.
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          return ChatScreen(
            chatId: args['chatId'] as String? ?? '',
            peerName: args['peerName'] as String? ?? 'KFUPM student',
            itemTitle: args['itemTitle'] as String? ?? '',
            itemPrice: (args['itemPrice'] as num?)?.toDouble() ?? 0,
          );
        },
        postListing: (_) => const PostListingScreen(),
        posted: (_) => const PostedScreen(),
        editProfile: (_) => const EditProfileScreen(),
        myListings: (_) => const MyListingsScreen(),
      };
}