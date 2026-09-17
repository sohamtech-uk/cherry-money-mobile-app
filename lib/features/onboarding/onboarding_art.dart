import 'package:flutter/material.dart';
import '../../core/widgets/motion.dart';

const onboardingAssets = [
  'assets/images/onboarding/finances.webp',
  'assets/images/onboarding/capture.webp',
  'assets/images/onboarding/review.webp',
];

/// Decorative, locally bundled artwork. A finite entrance plays for each step.
class OnboardingArt extends StatelessWidget {
  final int step;
  const OnboardingArt({super.key, required this.step});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AspectRatio(
      aspectRatio: 1.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: AnimatedSwitcher(
          duration: CherryMotion.reduced(context)
              ? Duration.zero
              : const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: .96, end: 1).animate(animation),
              child: child,
            ),
          ),
          child: _ArtScene(key: ValueKey(step), step: step),
        ),
      ),
    ),
  );
}

class _ArtScene extends StatelessWidget {
  final int step;
  const _ArtScene({super.key, required this.step});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: CherryMotion.reduced(context)
        ? Duration.zero
        : const Duration(milliseconds: 700),
    curve: Curves.easeOutCubic,
    builder: (context, progress, _) => Stack(
      fit: StackFit.expand,
      children: [
        Transform.translate(
          offset: Offset(0, 10 * (1 - progress)),
          child: Image.asset(
            onboardingAssets[step],
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ),
        Positioned(
          left: 14,
          bottom: 12,
          child: Opacity(
            opacity: progress,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - progress)),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .96),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE7E1DF)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D33282C),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      [
                        Icons.layers_outlined,
                        Icons.document_scanner_outlined,
                        Icons.fact_check_outlined,
                      ][step],
                      size: 16,
                      color: const Color(0xFF315F62),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      [
                        'One clear view',
                        'Less paperwork',
                        'You stay in control',
                      ][step],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF315F62),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
