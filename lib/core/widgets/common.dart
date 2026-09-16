import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/finance.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
}

class StatusBadge extends StatelessWidget {
  final ReconciliationStatus status;
  const StatusBadge(this.status, {super.key});
  @override
  Widget build(BuildContext context) => Chip(
    visualDensity: VisualDensity.compact,
    avatar: Icon(
      status == ReconciliationStatus.reconciled
          ? Icons.check_circle_outline
          : Icons.info_outline,
      size: 16,
    ),
    label: Text(status.label, style: const TextStyle(fontSize: 12)),
  );
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
              Row(
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
                    child: Text(
                      transaction.merchant,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    money(transaction.amountPence),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
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
