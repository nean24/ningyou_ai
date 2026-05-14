import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ningyou/core/l10n/app_localizations.dart';

void main() {
  testWidgets('loads Vietnamese and English translations', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Text(
            '${context.l10n.t('auth.signInWithGoogle')}|${context.l10n.t('auth.anonymous')}',
          ),
        ),
      ),
    );

    expect(find.text('Đăng nhập với Google|Tiếp tục ẩn danh'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Text(
            '${context.l10n.t('auth.signInWithGoogle')}|${context.l10n.t('auth.anonymous')}',
          ),
        ),
      ),
    );

    expect(
      find.text('Sign in with Google|Continue anonymously'),
      findsOneWidget,
    );
  });

  testWidgets('uses the system locale when no app locale is forced', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('vi')];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Text(context.l10n.t('nav.discover')),
        ),
      ),
    );

    expect(find.text('Khám phá'), findsOneWidget);
  });
}
