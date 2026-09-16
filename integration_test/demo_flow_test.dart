import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cherry_money_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('demo to reconciliation approval', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Try demo'));
    await tester.tap(find.text('Try demo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reconcile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Northstar Studio'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Approve match'));
    await tester.tap(find.text('Approve match'));
    await tester.pumpAndSettle();
    expect(find.text('Reconciled'), findsOneWidget);
  });
}
