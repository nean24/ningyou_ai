import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ningyou/core/l10n/app_localizations.dart';
import 'package:ningyou/core/theme/app_theme.dart';
import 'package:ningyou/features/auth/domain/auth_state.dart';
import 'package:ningyou/features/auth/presentation/auth_controller.dart';
import 'package:ningyou/features/auth/presentation/sign_in_screen.dart';

class _IdleAuthController extends AuthController {
  @override
  Future<AuthState> build() async => const AuthUnauthenticated();
}

void main() {
  Widget buildSubject() {
    return ProviderScope(
      overrides: [authControllerProvider.overrideWith(_IdleAuthController.new)],
      child: MaterialApp(
        locale: const Locale('vi'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: AppTheme.light,
        home: const SignInScreen(),
      ),
    );
  }

  testWidgets('prioritizes Google and anonymous sign-in first', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Đăng nhập với Google'), findsOneWidget);
    expect(find.text('Tiếp tục ẩn danh'), findsOneWidget);
    expect(find.text('Chưa có tài khoản?'), findsOneWidget);
    expect(find.text('Đăng ký bằng email'), findsOneWidget);
    expect(find.text('Đã có tài khoản email?'), findsOneWidget);
    expect(find.text('Đăng nhập bằng email'), findsOneWidget);
    expect(find.text('EMAIL'), findsNothing);
    expect(find.text('MẬT KHẨU'), findsNothing);
  });

  testWidgets('opens email sign-up form from the account prompt', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Đăng ký bằng email'));
    await tester.pumpAndSettle();

    expect(find.text('TÊN HIỂN THỊ'), findsOneWidget);
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('MẬT KHẨU'), findsOneWidget);
    expect(find.text('Đăng ký'), findsOneWidget);
    expect(find.text('Đăng nhập với Google'), findsNothing);
  });

  testWidgets('opens email sign-in form from the email prompt', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Đăng nhập bằng email'));
    await tester.pumpAndSettle();

    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('MẬT KHẨU'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('TÊN HIỂN THỊ'), findsNothing);
    expect(find.text('Đăng nhập với Google'), findsNothing);
  });
}
