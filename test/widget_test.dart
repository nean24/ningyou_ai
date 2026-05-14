import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ningyou/app.dart';
import 'package:ningyou/core/theme/app_theme.dart';
import 'package:ningyou/shared/widgets/ningyou/ningyou_avatar.dart';
import 'package:ningyou/shared/widgets/ningyou/ningyou_button.dart';
import 'package:ningyou/shared/widgets/ningyou/ningyou_chat_bubble.dart';
import 'package:ningyou/shared/widgets/ningyou/ningyou_composer.dart';

void main() {
  testWidgets('renders design system preview shell', (tester) async {
    await tester.pumpWidget(const NingyouApp());

    expect(find.text('Ningyou'), findsOneWidget);
    expect(find.text('Design system preview'), findsOneWidget);
    expect(find.text('Bắt đầu trò chuyện'), findsOneWidget);
  });

  testWidgets('light and dark themes build without errors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const Scaffold(body: Text('Theme probe')),
      ),
    );

    expect(find.text('Theme probe'), findsOneWidget);
  });

  testWidgets('primary and danger buttons render labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Column(
            children: [
              NingyouButton.primary(label: 'Bắt đầu trò chuyện'),
              NingyouButton.danger(label: 'Delete chat'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Bắt đầu trò chuyện'), findsOneWidget);
    expect(find.text('Delete chat'), findsOneWidget);
  });

  testWidgets('user and ai chat bubbles render text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Column(
            children: [
              NingyouChatBubble.ai(
                text: 'Chào bạn. Hôm nay bạn muốn ôn phần nào trước?',
              ),
              NingyouChatBubble.user(text: 'Văn trước nhé.'),
            ],
          ),
        ),
      ),
    );

    expect(
      find.text('Chào bạn. Hôm nay bạn muốn ôn phần nào trước?'),
      findsOneWidget,
    );
    expect(find.text('Văn trước nhé.'), findsOneWidget);
  });

  testWidgets('composer sends non-empty text', (tester) async {
    String? sentMessage;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: NingyouComposer(
            hintText: 'Viết tin nhắn cho Linh...',
            onSend: (message) => sentMessage = message,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.mic_none_rounded), findsNothing);

    await tester.enterText(find.byType(TextField), 'Xin chào Linh');
    await tester.tap(find.byKey(const ValueKey('ningyou_composer_send')));
    await tester.pump();

    expect(sentMessage, 'Xin chào Linh');
  });

  testWidgets('avatar renders initials and status indicator', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: NingyouAvatar(
            initials: 'L',
            size: NingyouAvatarSize.md,
            gradient: NingyouAvatarGradient.green,
            showStatus: true,
          ),
        ),
      ),
    );

    expect(find.text('L'), findsOneWidget);
    expect(find.byKey(const ValueKey('ningyou_avatar_status')), findsOneWidget);
  });
}
