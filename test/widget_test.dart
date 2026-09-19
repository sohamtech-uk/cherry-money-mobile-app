import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cherry_money_mobile/app/app.dart';
import 'package:cherry_money_mobile/core/revenuecat/revenuecat_service.dart';
import 'package:cherry_money_mobile/core/revenuecat/subscription_state.dart';
import 'package:cherry_money_mobile/data/repositories/workspace.dart';

class FakeSubscriptions implements SubscriptionRepository {
  @override
  Future<void> initialize() async {}
  @override
  Future<Plan> refresh() async => Plan.launch;
  @override
  Future<List<Package>> offerings() async => [];
  @override
  Future<Plan> purchase(Package package) async =>
      throw StateError('No fake purchases');
  @override
  Future<Plan> restore() async => Plan.launch;
}

Future<Workspace> launch(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final workspace = Workspace(subscriptions: FakeSubscriptions());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [workspaceProvider.overrideWith((ref) => workspace)],
      child: const CherryApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Try demo'));
  await tester.tap(find.text('Try demo'));
  await tester.pumpAndSettle();
  return workspace;
}

void main() {
  testWidgets('demo dashboard renders visible synthetic label and balances', (
    tester,
  ) async {
    await launch(tester);
    expect(
      find.text('Demo data · Synthetic finance workspace'),
      findsOneWidget,
    );
    expect(find.text('£8,420.50'), findsOneWidget);
    expect(find.text('Capture receipt or invoice'), findsOneWidget);
  });
  testWidgets(
    'reconciliation exceptions render and approval updates audit and status',
    (tester) async {
      final workspace = await launch(tester);
      await tester.tap(find.text('Reconcile'));
      await tester.pumpAndSettle();
      expect(find.text('Only what needs you.'), findsOneWidget);
      expect(find.text('Cloud Office'), findsOneWidget);
      await tester.tap(find.text('Northstar Studio'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Approve match'));
      await tester.tap(find.text('Approve match'));
      await tester.pumpAndSettle();
      expect(workspace.reconciled, 1);
      expect(find.text('Reconciled'), findsOneWidget);
      expect(
        find.text(
          'You approved the document match. Demo reconciliation completed.',
        ),
        findsOneWidget,
      );
    },
  );
  testWidgets('premium insight routes free user to real-offering paywall', (
    tester,
  ) async {
    await launch(tester);
    await tester.tap(find.text('Ask Cherry'));
    await tester.pumpAndSettle();
    final prompt = find.text(
      'What changed in my cash position this week? · Flow',
    );
    await tester.ensureVisible(prompt);
    await tester.tap(prompt);
    await tester.pumpAndSettle();
    expect(find.text('Your Cherry plan'), findsOneWidget);
    expect(find.text('Launch'), findsOneWidget);
    expect(find.text('Flow'), findsOneWidget);
    expect(find.text('Thrive'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(
      find.text('No plans are currently available to purchase.'),
      findsOneWidget,
    );
    expect(find.text('Continue to store purchase'), findsNothing);
  });
  testWidgets(
    'capture sample reaches review and attaches a synthetic document',
    (tester) async {
      final workspace = await launch(tester);
      await tester.ensureVisible(find.text('Capture receipt or invoice'));
      await tester.tap(find.text('Capture receipt or invoice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Use sample receipt'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show demo extraction'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.ensureVisible(find.text('Confirm and review match'));
      await tester.tap(find.text('Confirm and review match'));
      await tester.pumpAndSettle();
      expect(workspace.transactions[3].document?.supplier, 'Station Road Cafe');
      expect(find.text('Review transaction'), findsOneWidget);
    },
  );
}
