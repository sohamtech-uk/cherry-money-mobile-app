import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cherry_money_mobile/core/config/app_config.dart';
import 'package:cherry_money_mobile/core/network/api_client.dart';
import 'package:cherry_money_mobile/data/repositories/workspace.dart';
import 'package:cherry_money_mobile/features/live/ask_cherry_screen.dart';
import 'package:cherry_money_mobile/features/live/banking_screen.dart';
import 'api_client_test.dart' show MemoryStorage, ContractAdapter, jsonResponse;

ApiClient api() =>
    ApiClient(const AppConfig(), MemoryStorage()..token = 'fixture');
Future<void> showScreen(
  WidgetTester tester,
  Workspace state,
  Widget child,
) async {
  tester.view.physicalSize = const Size(1000, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [workspaceProvider.overrideWith((ref) => state)],
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test(
    'finance requests authenticate and preserve server validation failures',
    () async {
      final client = api();
      client.dio.httpClientAdapter = ContractAdapter((r) {
        expect(r.headers['Authorization'], 'Bearer fixture');
        return jsonResponse({
          'errors': {
            'amount': ['Amount exceeds the outstanding balance.'],
          },
        }, 422);
      });
      await expectLater(
        client.financeRequest(
          'mobile/expense',
          method: 'POST',
          data: {'amount': 20},
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Amount exceeds the outstanding balance.',
          ),
        ),
      );
      await expectLater(
        client.financeRequest('https://elsewhere.example/data'),
        throwsA(isA<ApiException>()),
      );
    },
  );
  test(
    'Ask Cherry sends bounded history and only user assistant roles',
    () async {
      final client = api();
      client.dio.httpClientAdapter = ContractAdapter((r) {
        expect(r.path, 'webmcp/ask');
        expect(r.data['message'], 'What is overdue?');
        final history = r.data['history'] as List;
        expect(history.length, 10);
        expect(history.first['content'].length, 2000);
        return jsonResponse({
          'reply': 'The current records show one overdue invoice.',
        });
      });
      final response = await client.askCherry(
        'What is overdue?',
        List.generate(12, (i) => {'role': 'user', 'content': 'a' * 2300}),
      );
      expect(response['reply'], contains('overdue invoice'));
    },
  );
  testWidgets(
    'live Ask Cherry uses the backend reply and retains conversation for followups',
    (tester) async {
      final client = api();
      int calls = 0;
      client.dio.httpClientAdapter = ContractAdapter((r) {
        calls++;
        expect(r.path, 'webmcp/ask');
        if (calls == 2) expect((r.data['history'] as List).length, 2);
        return jsonResponse({
          'reply': calls == 1
              ? 'Invoice CM-55 is overdue by 3 days.'
              : 'CM-55 is for £120.',
        });
      });
      final state = Workspace(api: client)..signedIn = true;
      await showScreen(tester, state, const AskCherryScreen());
      await tester.enterText(
        find.byType(TextField),
        'Which invoice is overdue?',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Ask Cherry'));
      await tester.pumpAndSettle();
      expect(find.text('Invoice CM-55 is overdue by 3 days.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'How much?');
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Ask Cherry'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Ask Cherry'));
      await tester.pumpAndSettle();
      expect(find.text('CM-55 is for £120.'), findsOneWidget);
      expect(calls, 2);
    },
  );
  testWidgets(
    'reconciliation approval is sent only after explicit human confirmation',
    (tester) async {
      final client = api();
      int approvals = 0;
      client.dio.httpClientAdapter = ContractAdapter((r) {
        if (r.path.endsWith('/approve')) {
          approvals++;
          expect(r.headers['X-Cherry-Human-Approval'], 'confirmed');
          expect(r.data['confirmation'], true);
          return jsonResponse({'reconciliationCompleted': true});
        }
        return jsonResponse({
          'capabilities': {'humanApproveReconciliation': true},
          'transactions': [],
          'approvals': approvals > 0
              ? []
              : [
                  {
                    'id': 'p1',
                    'amount': 120,
                    'currency': 'GBP',
                    'reason': 'Invoice CM-55 matches this bank payment.',
                  },
                ],
        });
      });
      final state = Workspace(api: client)..signedIn = true;
      await showScreen(tester, state, const BankingScreen(reconcile: true));
      await tester.tap(find.text('Review approval'));
      await tester.pumpAndSettle();
      expect(approvals, 0);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(approvals, 0);
      await tester.tap(find.text('Review approval'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Approve match'));
      await tester.pumpAndSettle();
      expect(approvals, 1);
      expect(find.text('Review approval'), findsNothing);
    },
  );
  test('switching to demo clears live data and chat', () async {
    SharedPreferences.setMockInitialValues({});
    final state = Workspace(api: api())
      ..signedIn = true
      ..liveFinance = {
        'accounts': [
          {'name': 'Real company'},
        ],
      };
    state.cherryHistory.add({
      'role': 'assistant',
      'content': 'Private records',
    });
    await state.startDemo();
    expect(state.liveFinance, isNull);
    expect(state.cherryHistory, isEmpty);
  });
}
