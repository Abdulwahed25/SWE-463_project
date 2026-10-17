import 'package:flutter/material.dart';

import 'screens/chat_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/listing_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
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
        chat: (_) => const ChatScreen(),
        postListing: (_) => const PostListingScreen(),
        posted: (_) => const PostedScreen(),
        editProfile: (_) => const EditProfileScreen(),
        myListings: (_) => const MyListingsScreen(),
      };
}
