import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cherry_money_mobile/core/widgets/motion.dart';
import 'package:cherry_money_mobile/core/widgets/common.dart';
import 'package:cherry_money_mobile/core/models/finance.dart';
import 'package:cherry_money_mobile/data/demo/demo_data.dart';
import 'package:cherry_money_mobile/features/dashboard/finance_overview.dart';

Widget host(Widget child, {bool reduced = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: Scaffold(body: child),
  ),
);

void main() {
  testWidgets(
    'reduced motion reveals content immediately and uses a static busy indicator',
    (tester) async {
      await tester.pumpWidget(
        host(
          const PageEntrance(
            child: ActionLabel(
              busy: true,
              label: 'Approve',
              busyLabel: 'Checking…',
            ),
          ),
          reduced: true,
        ),
      );
      final fade = tester.widget<FadeTransition>(
        find
            .descendant(
              of: find.byType(PageEntrance),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, 1);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Checking…'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
    },
  );
  testWidgets(
    'page entrance runs once and settles without looping or changing financial text',
    (tester) async {
      const key = ValueKey('page');
      await tester.pumpWidget(
        host(const PageEntrance(key: key, child: Text('£8,420.50'))),
      );
      final fade = tester.widget<FadeTransition>(
        find
            .descendant(
              of: find.byType(PageEntrance),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, lessThan(1));
      expect(find.text('£8,420.50'), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        host(const PageEntrance(key: key, child: Text('£8,500.00'))),
      );
      expect(fade.opacity.value, 1);
      expect(find.text('£8,500.00'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
    },
  );
  testWidgets('changing motion preference completes an in-flight entrance', (
    tester,
  ) async {
    const child = PageEntrance(key: ValueKey('page'), child: Text('Balance'));
    await tester.pumpWidget(host(child));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(host(child, reduced: true));
    final fade = tester.widget<FadeTransition>(
      find
          .descendant(
            of: find.byType(PageEntrance),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('status changes remove the stale status during the animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const StatusBadge(ReconciliationStatus.needsReview)),
    );
    await tester.pumpWidget(
      host(const StatusBadge(ReconciliationStatus.reconciled)),
    );
    expect(find.text(ReconciliationStatus.needsReview.label), findsNothing);
    expect(find.text('Reconciled'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'cash summary and transaction cards fit a narrow screen with large text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const FinanceOverview(incoming: 125000, outgoing: 159249),
                    TransactionCard(demoTransactions().first, onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
