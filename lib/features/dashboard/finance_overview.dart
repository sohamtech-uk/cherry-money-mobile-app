import 'package:flutter/material.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/motion.dart';

class FinanceOverview extends StatelessWidget {
  final int incoming, outgoing;
  const FinanceOverview({
    super.key,
    required this.incoming,
    required this.outgoing,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF412732), Color(0xFF211F2C)],
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(
          color: Color(0x2030262C),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFFE9CCD4),
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Demo cash balance',
                style: TextStyle(color: Color(0xFFE9CCD4)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          '£8,420.50',
          style: TextStyle(
            fontSize: 38,
            letterSpacing: -1.2,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'A snapshot of your example business',
          style: TextStyle(color: Color(0xFFC7BCC4), fontSize: 12),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(height: 1, color: Color(0xFF61505A)),
        ),
        Wrap(
          spacing: 28,
          runSpacing: 16,
          children: [
            _CashMetric(label: 'Money in', amount: incoming, incoming: true),
            _CashMetric(label: 'Money out', amount: outgoing, incoming: false),
          ],
        ),
      ],
    ),
  );
}

class _CashMetric extends StatelessWidget {
  final String label;
  final int amount;
  final bool incoming;
  const _CashMetric({
    required this.label,
    required this.amount,
    required this.incoming,
  });
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          incoming ? Icons.south_west_rounded : Icons.north_east_rounded,
          size: 17,
          color: incoming ? const Color(0xFFA4DFCB) : const Color(0xFFF1B7BE),
        ),
      ),
      const SizedBox(width: 9),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFFC7BCC4), fontSize: 12),
            ),
            Text(
              money(amount),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class ReviewProgress extends StatelessWidget {
  final int reviewed, total;
  const ReviewProgress({
    super.key,
    required this.reviewed,
    required this.total,
  });
  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : (reviewed / total).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Semantics(
              label: 'Review progress',
              value: '$reviewed of $total reconciled',
              excludeSemantics: true,
              child: SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: fraction, end: fraction),
                      duration: CherryMotion.duration(context),
                      builder: (_, value, _) => SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 4,
                          strokeCap: StrokeCap.round,
                          color: const Color(0xFF207151),
                          backgroundColor: const Color(0xFFE7EFEB),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.fact_check_outlined,
                      color: Color(0xFF207151),
                      size: 23,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your review progress',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$reviewed of $total transactions reconciled',
                    style: const TextStyle(
                      color: Color(0xFF68636A),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
