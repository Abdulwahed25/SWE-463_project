import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:souq/models/listing.dart';
import 'package:souq/models/user.dart';
import 'package:souq/providers/chat_provider.dart';
import 'package:souq/screens/chat_screen.dart';

import 'fake_chat_repository.dart';

const buyer = User(id: 'u_buyer', name: 'Sara', email: 'sara@kfupm.edu.sa', studentId: '202300001');
const seller = User(id: 'u_seller', name: 'Omar', email: 'omar@kfupm.edu.sa', studentId: '202300002');

final listing = Listing(
  id: 'l1',
  title: 'Calculus textbook',
  price: 60,
  category: 'Books',
  condition: 'Used',
  location: 'Building 22',
  description: 'Good condition',
  sellerId: seller.id,
  sellerName: seller.name,
  createdAt: DateTime(2026, 11, 1),
);

/// Lets the microtask in setUser and the fake repository calls finish.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('ChatProvider', () {
    late FakeChatRepository repo;
    late ChatProvider provider;

    setUp(() {
      repo = FakeChatRepository();
      provider = ChatProvider(repo);
    });

    test('guest has no chats and cannot open a chat', () async {
      provider.setUser(null);
      await settle();
      expect(provider.chats, isEmpty);
      expect(await provider.openChatForListing(listing), isNull);
    });

    test('seller cannot message their own listing', () async {
      provider.setUser(seller);
      await settle();
      expect(await provider.openChatForListing(listing), isNull);
    });

    test('Message seller creates one chat and reuses it', () async {
      provider.setUser(buyer);
      await settle();

      final first = await provider.openChatForListing(listing);
      final second = await provider.openChatForListing(listing);

      expect(first!.id, second!.id);
      expect(provider.chats.length, 1);
      expect(first.peerName(buyer.id), 'Omar');
    });

    test('empty message is rejected', () async {
      provider.setUser(buyer);
      await settle();
      final chat = await provider.openChatForListing(listing);

      expect(await provider.sendMessage(chatId: chat!.id, text: '   '), isFalse);
      expect(repo.messages[chat.id], isNull);
    });

    test('sent message shows in the chat and is unread for the seller', () async {
      provider.setUser(buyer);
      await settle();
      final chat = await provider.openChatForListing(listing);
      await provider.enterChat(chat!.id);

      final ok = await provider.sendMessage(chatId: chat.id, text: ' Is it available? ');

      expect(ok, isTrue);
      expect(provider.activeMessages.first.text, 'Is it available?');
      expect(provider.chats.first.lastMessage, 'Is it available?');

      // The seller logs in: the chat is there with 1 unread message.
      provider.setUser(seller);
      await settle();
      expect(provider.chats.length, 1);
      expect(provider.unreadTotal, 1);
      expect(provider.chats.first.peerName(seller.id), 'Sara');

      // Opening the chat marks it as read.
      await provider.enterChat(chat.id);
      expect(provider.unreadTotal, 0);
    });

    test('load error is shown and send failure returns false', () async {
      provider.setUser(buyer);
      await settle();
      final chat = await provider.openChatForListing(listing);

      repo.shouldFail = true;
      await provider.loadChats();
      expect(provider.errorMessage, isNotNull);
      expect(await provider.sendMessage(chatId: chat!.id, text: 'Hi'), isFalse);
    });

    test('logout clears the chats', () async {
      provider.setUser(buyer);
      await settle();
      await provider.openChatForListing(listing);

      provider.setUser(null);
      await settle();
      expect(provider.chats, isEmpty);
    });
  });

  group('ChatScreen', () {
    testWidgets('shows a message after Send and rejects an empty one', (tester) async {
      final repo = FakeChatRepository();
      final provider = ChatProvider(repo)..setUser(buyer);
      final chat = await provider.openChatForListing(listing);

      await tester.pumpWidget(
        ChangeNotifierProvider<ChatProvider>.value(
          value: provider,
          child: MaterialApp(
            home: ChatScreen(
              chatId: chat!.id,
              peerName: 'Omar',
              itemTitle: 'Calculus textbook',
              itemPrice: 60,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No messages yet'), findsOneWidget);

      // Empty message: a hint is shown and nothing is sent.
      await tester.tap(find.byKey(const Key('chat_send')));
      await tester.pump();
      expect(find.text('Type a message first.'), findsOneWidget);

      // Real message: it appears in the list.
      await tester.enterText(find.byKey(const Key('chat_input')), 'Hello Omar');
      await tester.tap(find.byKey(const Key('chat_send')));
      await tester.pumpAndSettle();
      expect(find.text('Hello Omar'), findsOneWidget);
    });
  });
}
