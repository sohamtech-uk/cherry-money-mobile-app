import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/workspace.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/cherry_logo.dart';
import '../../core/widgets/motion.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int step = 0;
  static const titles = [
    'Connect your finances',
    'Let Cherry handle routine finance work',
    'Review only what needs you',
  ];
  static const subtitles = [
    'Your business, with a little more clarity. Bring invoices, receipts and decisions into one calm workspace.',
    'Capture a document, inspect the extracted details and see the evidence behind a possible transaction match.',
    'Check exceptions, approve matches and follow every decision in your activity timeline.',
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: PageBody(
        children: [
          const SizedBox(height: 24),
          const CherryLogo(),
          const SizedBox(height: 28),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E5E7),
              borderRadius: BorderRadius.circular(32),
            ),
            child: StateReveal(
              child: Icon(
                key: ValueKey(step),
                [
                  Icons.account_balance_wallet_outlined,
                  Icons.document_scanner_outlined,
                  Icons.fact_check_outlined,
                ][step],
                size: 88,
                color: const Color(0xFFAD1929),
              ),
            ),
          ),
          const SizedBox(height: 32),
          StateReveal(
            child: Text(
              titles[step],
              key: ValueKey('title-$step'),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: 16),
          StateReveal(
            child: Text(subtitles[step], key: ValueKey('subtitle-$step')),
          ),
          const SizedBox(height: 24),
          Semantics(
            label: 'Onboarding page ${step + 1} of 3',
            excludeSemantics: true,
            child: Row(
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: CherryMotion.duration(context),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(right: 6),
                  height: 6,
                  width: index == step ? 32 : 8,
                  decoration: BoxDecoration(
                    color: index == step
                        ? const Color(0xFFAD1929)
                        : const Color(0xFFE0D6DA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              if (step < 2) {
                setState(() => step++);
              } else {
                context.go('/login');
              }
            },
            child: Text(step < 2 ? 'Continue' : 'Get started'),
          ),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Sign in'),
          ),
          OutlinedButton(
            onPressed: () => context.go('/signup'),
            child: const Text('Create new account'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(workspaceProvider).startDemo();
              if (context.mounted) {
                context.go('/home');
              }
            },
            child: const Text('Try demo'),
          ),
          const Text(
            'A finance workspace for small businesses.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
