import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/workspace.dart';
import '../../core/widgets/cherry_logo.dart';
import '../../core/widgets/motion.dart';
import 'onboarding_art.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int step = 0;
  bool assetsRequested = false;
  static const titles = [
    'Your finances.\nAll together.',
    'Less paperwork.\nMore possibility.',
    'A clear picture.\nA confident decision.',
  ];
  static const subtitles = [
    'Bring invoices, receipts and everyday finance decisions into one calm workspace.',
    'Capture a receipt, check the details and find the transaction it belongs to.',
    'See the evidence, resolve exceptions and approve matches. You stay in control.',
  ];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!assetsRequested) {
      assetsRequested = true;
      // Local files; preloading prevents a blank frame between onboarding steps.
      for (final asset in onboardingAssets) {
        precacheImage(AssetImage(asset), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: PageEntrance(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 112, child: CherryLogo(height: 66)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Sign in'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OnboardingArt(step: step),
                  const SizedBox(height: 24),
                  Text(
                    [
                      'FINANCES, SIMPLIFIED',
                      'FROM RECEIPT TO RECORD',
                      'CLARITY BEFORE EVERY DECISION',
                    ][step],
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: Color(0xFF9E3547),
                    ),
                  ),
                  const SizedBox(height: 10),
                  StateReveal(
                    child: Text(
                      titles[step],
                      key: ValueKey('title-$step'),
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontSize: 32, height: 1.13),
                    ),
                  ),
                  const SizedBox(height: 12),
                  StateReveal(
                    child: Text(
                      subtitles[step],
                      key: ValueKey('subtitle-$step'),
                      style: const TextStyle(
                        color: Color(0xFF68636A),
                        height: 1.55,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
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
                              width: index == step ? 28 : 7,
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
                      const Spacer(),
                      if (step > 0)
                        TextButton.icon(
                          onPressed: () => setState(() => step--),
                          icon: const Icon(Icons.arrow_back_rounded, size: 16),
                          label: const Text('Back'),
                        )
                      else
                        const SizedBox(height: 48),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () {
                      if (step < 2) {
                        setState(() => step++);
                      } else {
                        context.go('/login');
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(step < 2 ? 'Continue' : 'Get started'),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
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
                    'Explore with sample data. No bank connection needed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Color(0xFF68636A)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
