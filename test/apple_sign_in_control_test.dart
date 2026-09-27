import 'dart:async';
import 'package:cherry_money_mobile/core/network/api_client.dart';
import 'package:cherry_money_mobile/features/auth/apple_auth_service.dart';
import 'package:cherry_money_mobile/features/auth/apple_sign_in_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FakeAppleService extends AppleAuthService {
  bool available = true;
  Object? authenticationError;
  Completer<String>? pendingAuthentication;
  @override
  bool get configured => available;
  @override
  Future<String> authenticate() async {
    if (authenticationError case final error?) throw error;
    return pendingAuthentication?.future ?? Future.value('signed-token');
  }
}

void main() {
  Future<void> mount(
    WidgetTester tester,
    FakeAppleService service, {
    required Future<void> Function(String) exchange,
    ValueChanged<bool>? busy,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppleSignInControl(
            service: service,
            onToken: exchange,
            onBusyChanged: busy ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('unconfigured Apple sign-in renders nothing', (tester) async {
    final service = FakeAppleService()..available = false;
    await mount(
      tester,
      service,
      exchange: (_) async => fail('Must not exchange'),
    );
    expect(find.byType(SignInWithAppleButton), findsNothing);
    expect(find.text('Continue with Apple'), findsNothing);
  });

  testWidgets('successful sign-in exchanges the signed token', (tester) async {
    final received = <String>[];
    final service = FakeAppleService();
    await mount(
      tester,
      service,
      exchange: (token) async {
        received.add(token);
      },
    );
    await tester.tap(find.byType(SignInWithAppleButton));
    await tester.pumpAndSettle();
    expect(received, ['signed-token']);
  });

  testWidgets('cancellation restores controls and does not exchange', (
    tester,
  ) async {
    final service = FakeAppleService()
      ..authenticationError = const SignInWithAppleAuthorizationException(
        code: AuthorizationErrorCode.canceled,
        message: 'cancelled',
      );
    final states = <bool>[];
    await mount(
      tester,
      service,
      exchange: (_) async => fail('Must not exchange'),
      busy: states.add,
    );
    await tester.tap(find.byType(SignInWithAppleButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('was cancelled'), findsOneWidget);
    expect(states, [true, false]);
    expect(
      tester
          .widget<SignInWithAppleButton>(find.byType(SignInWithAppleButton))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets(
    'authentication completed after navigation cannot create a session',
    (tester) async {
      final pending = Completer<String>();
      final service = FakeAppleService()..pendingAuthentication = pending;
      await mount(
        tester,
        service,
        exchange: (_) async => fail('Must not exchange'),
      );
      await tester.tap(find.byType(SignInWithAppleButton));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      pending.complete('late-native-token');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('backend rejection surfaces the returned message', (
    tester,
  ) async {
    final service = FakeAppleService();
    final pending = Completer<void>();
    await mount(tester, service, exchange: (_) => pending.future);
    await tester.tap(find.byType(SignInWithAppleButton));
    await tester.pump();
    pending.completeError(
      const ApiException('Complete account verification first.'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Complete account verification first.'), findsOneWidget);
  });
}
