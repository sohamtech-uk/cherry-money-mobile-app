import 'dart:async';
import 'package:cherry_money_mobile/core/network/api_client.dart';
import 'package:cherry_money_mobile/features/auth/google_auth_service.dart';
import 'package:cherry_money_mobile/features/auth/google_sign_in_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FakeGoogleService extends GoogleAuthService {
  bool available = true;
  bool web = false;
  Object? initializationError;
  Object? authenticationError;
  Completer<String>? pendingAuthentication;
  int initializations = 0;
  final events = StreamController<String>.broadcast();
  @override
  bool get configured => available;
  @override
  bool get usesWebButton => web;
  @override
  Stream<String> get tokens => events.stream;
  @override
  Future<void> initialize() async {
    initializations++;
    if (initializationError case final error?) throw error;
  }

  @override
  Future<String> authenticate() async {
    if (authenticationError case final error?) throw error;
    return pendingAuthentication?.future ?? Future.value('signed-token');
  }
}

void main() {
  Future<void> mount(
    WidgetTester tester,
    FakeGoogleService service, {
    required Future<void> Function(String) exchange,
    ValueChanged<bool>? busy,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoogleSignInControl(
            service: service,
            onToken: exchange,
            onBusyChanged: busy ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('unconfigured Google is disabled without initializing SDK', (
    tester,
  ) async {
    final service = FakeGoogleService()..available = false;
    await mount(
      tester,
      service,
      exchange: (_) async => fail('Must not exchange'),
    );
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );
    expect(service.initializations, 0);
    expect(find.textContaining('not enabled in this version'), findsOneWidget);
  });

  testWidgets('SDK load failure can be retried', (tester) async {
    final service = FakeGoogleService()
      ..initializationError = Exception('Offline');
    await mount(tester, service, exchange: (_) async {});
    expect(find.textContaining('Check your connection'), findsOneWidget);
    service.initializationError = null;
    await tester.tap(find.text('Retry Google sign-in'));
    await tester.pumpAndSettle();
    expect(service.initializations, 2);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('cancellation restores controls and does not exchange', (
    tester,
  ) async {
    final service = FakeGoogleService()
      ..authenticationError = const GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
      );
    final states = <bool>[];
    await mount(
      tester,
      service,
      exchange: (_) async => fail('Must not exchange'),
      busy: states.add,
    );
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.textContaining('was cancelled'), findsOneWidget);
    expect(states, [true, false]);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets(
    'web events exchange once while pending and surface backend rejection',
    (tester) async {
      final service = FakeGoogleService()..web = true;
      final pending = Completer<void>();
      final received = <String>[];
      await mount(
        tester,
        service,
        exchange: (token) {
          received.add(token);
          return pending.future;
        },
      );
      service.events.add('web-token');
      service.events.add('duplicate');
      await tester.pump();
      expect(received, ['web-token']);
      pending.completeError(
        const ApiException('Complete account verification first.'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Complete account verification first.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      expect(service.events.hasListener, false);
      await service.events.close();
    },
  );

  testWidgets('late web tokens after leaving login are ignored', (
    tester,
  ) async {
    final service = FakeGoogleService()..web = true;
    await mount(
      tester,
      service,
      exchange: (_) async => fail('Must not exchange'),
    );
    await tester.pumpWidget(const SizedBox());
    service.events.add('late-token');
    await tester.pump();
    expect(tester.takeException(), isNull);
    await service.events.close();
  });
  testWidgets(
    'native authentication completed after navigation cannot create a session',
    (tester) async {
      final pending = Completer<String>();
      final service = FakeGoogleService()..pendingAuthentication = pending;
      await mount(
        tester,
        service,
        exchange: (_) async => fail('Must not exchange'),
      );
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      pending.complete('late-native-token');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
