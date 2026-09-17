import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/finance.dart';
import 'motion.dart';

String money(int pence) =>
    NumberFormat.currency(locale: 'en_GB', symbol: '£').format(pence / 100);

class PageBody extends StatelessWidget {
  final List<Widget> children;
  const PageBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: PageEntrance(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    ),
  );
}

class StatusBadge extends StatelessWidget {
  final ReconciliationStatus status;
  const StatusBadge(this.status, {super.key});
  @override
  Widget build(BuildContext context) {
    final done = status == ReconciliationStatus.reconciled;
    final problem =
        status == ReconciliationStatus.amountMismatch ||
        status == ReconciliationStatus.duplicateCandidate;
    final color = done
        ? const Color(0xFF207151)
        : problem
        ? const Color(0xFFA12535)
        : const Color(0xFF805700);
    return Align(
      alignment: Alignment.centerLeft,
      child: StateReveal(
        child: Chip(
          key: ValueKey(status),
          visualDensity: VisualDensity.compact,
          backgroundColor: color.withValues(alpha: .07),
          side: BorderSide(color: color.withValues(alpha: .18)),
          avatar: Icon(
            done ? Icons.check_circle_rounded : Icons.info_outline,
            color: color,
            size: 16,
          ),
          label: Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final FinanceTransaction transaction;
  final VoidCallback onTap;
  const TransactionCard(this.transaction, {super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    onTap: onTap,
    excludeSemantics: true,
    label:
        '${transaction.merchant}, ${money(transaction.amountPence)}, ${transaction.status.label}, ${transaction.reference}. Open transaction',
    child: Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked =
                      constraints.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.3;
                  final merchant = Text(
                    transaction.merchant,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  );
                  final amount = Text(
                    money(transaction.amountPence),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  );
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFF6ECEE),
                        child: Icon(
                          transaction.amountPence > 0
                              ? Icons.south_west
                              : Icons.north_east,
                          color: const Color(0xFFAD1929),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: stacked
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  merchant,
                                  const SizedBox(height: 4),
                                  amount,
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: merchant),
                                  const SizedBox(width: 8),
                                  amount,
                                ],
                              ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                '${transaction.reference} · ${DateFormat('d MMM').format(transaction.date)}',
              ),
              StatusBadge(transaction.status),
            ],
          ),
        ),
      ),
    ),
  );
}

class Notice extends StatelessWidget {
  final String text;
  const Notice(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF4EDEF),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(text),
  );
}
