import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cherry_money_mobile/core/config/app_config.dart';
import 'package:cherry_money_mobile/core/models/finance.dart';
import 'package:cherry_money_mobile/core/revenuecat/subscription_state.dart';
import 'package:cherry_money_mobile/data/demo/demo_data.dart';
import 'package:cherry_money_mobile/data/repositories/workspace.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('environment defaults use HTTPS and production is explicit', () {
    expect(const AppConfig().apiBaseUrl, 'https://dev.cherrymoney.co.uk/api/');
    expect(
      const AppConfig(environment: 'production').apiBaseUrl,
      'https://cherrymoney.co.uk/api/',
    );
    expect(const AppConfig(apiBaseUrl: 'http://unsafe/api/').valid, false);
    expect(const AppConfig(environment: 'unknown').valid, false);
  });
  test('higher tiers take precedence and legacy entitlements migrate', () {
    expect(
      planForEntitlements(['cherrymoney_flow', 'cherrymoney_practice']),
      Plan.practice,
    );
    expect(planForEntitlements(['cherrymoney_thrive']), Plan.thrive);
    expect(planForEntitlements(['cherrymoney_flow']), Plan.flow);
    expect(planForEntitlements(['cherrymoney_sole_trader']), Plan.soleTrader);
    expect(planForEntitlements(['pro']), Plan.flow);
    expect(planForEntitlements(['cherrymoney_pro']), Plan.flow);
    expect(planForEntitlements(['business']), Plan.practice);
    expect(planForEntitlements(['admin']), Plan.launch);
    expect(canProcess(Plan.launch, 2), true);
    expect(canProcess(Plan.launch, 3), false);
    expect(canProcess(Plan.soleTrader, 49), true);
    expect(canProcess(Plan.soleTrader, 50), false);
    expect(canProcess(Plan.flow, 100), false);
    expect(canProcess(Plan.thrive, 249), true);
    expect(canProcess(Plan.practice, 499), true);
  });
  test(
    'matching explains high-confidence candidates without finalizing them',
    () {
      final t = demoTransactions().first;
      final result = evaluateMatch(t, t.document);
      expect(result.status, ReconciliationStatus.suggestedMatch);
      expect(result.confidence, closeTo(1, .001));
      expect(result.reasons, contains('Invoice reference found'));
    },
  );
  test(
    'mismatch, duplicate, absent and low-confidence evidence require review',
    () {
      final t = demoTransactions();
      expect(
        evaluateMatch(t[2], t[2].document).status,
        ReconciliationStatus.amountMismatch,
      );
      expect(
        evaluateMatch(t[3], null).status,
        ReconciliationStatus.missingDocument,
      );
      expect(
        evaluateMatch(t[4], t[4].document).status,
        ReconciliationStatus.duplicateCandidate,
      );
      expect(
        evaluateMatch(t[5], t[5].document).status,
        ReconciliationStatus.needsReview,
      );
    },
  );
  test(
    'approval changes status, appends actor audit and consumes only once',
    () async {
      final state = Workspace();
      await state.startDemo();
      expect(await state.approve('t1'), true);
      expect(state.reconciled, 1);
      final event = state.transactions.first.audit.last;
      expect(event.action, 'approved');
      expect(event.actorType, 'user');
      expect(event.entityId, 't1');
      expect(event.id, isNotEmpty);
      expect(state.used, 1);
      await state.approve('t1');
      expect(state.used, 1);
    },
  );
  test('unsafe approvals do not consume allowance', () async {
    final state = Workspace();
    await state.startDemo();
    for (final id in ['t3', 't4', 't5']) {
      expect(await state.approve(id), false);
    }
    expect(state.used, 0);
  });
  test('free allowance persists across demo restart', () async {
    final state = Workspace();
    await state.startDemo();
    await state.approve('t1');
    await state.approve('t2');
    await state.approve('t6');
    await state.startDemo();
    expect(state.used, 3);
    expect(await state.approve('t1'), false);
    state.setPlan(Plan.flow);
    expect(await state.approve('t1'), true);
  });
  test(
    'selecting another transaction unlinks source and recomputes mismatch',
    () async {
      final state = Workspace();
      await state.startDemo();
      expect(state.chooseTransaction('t1', 't4'), true);
      expect(state.transactions.first.document, isNull);
      expect(state.transactions[3].status, ReconciliationStatus.amountMismatch);
      expect(state.transactions[3].audit.last.action, 'linked');
    },
  );
  test(
    'duplicate warning survives rejection and exception decisions',
    () async {
      final state = Workspace();
      await state.startDemo();
      state.reject('t5');
      expect(await state.approve('t5'), false);
      state.exception('t5');
      expect(await state.approve('t5'), false);
      expect(state.used, 0);
    },
  );
}
