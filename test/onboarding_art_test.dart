import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cherry_money_mobile/app/app.dart';
import 'package:cherry_money_mobile/features/onboarding/onboarding_art.dart';

void main() {
  for (final reduced in [false, true]) {
    testWidgets(
      'illustrated onboarding advances and returns with reduced motion $reduced',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(disableAnimations: reduced);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        await tester.pumpWidget(const ProviderScope(child: CherryApp()));
        await tester.pumpAndSettle();
        expect(
          tester.widget<OnboardingArt>(find.byType(OnboardingArt)).step,
          0,
        );
        for (final step in [1, 2]) {
          await tester.ensureVisible(find.text('Continue'));
          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();
          expect(
            tester.widget<OnboardingArt>(find.byType(OnboardingArt)).step,
            step,
          );
          expect(tester.binding.transientCallbackCount, 0);
        }
        expect(find.text('Get started'), findsOneWidget);
        await tester.ensureVisible(find.text('Back'));
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<OnboardingArt>(find.byType(OnboardingArt)).step,
          1,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
