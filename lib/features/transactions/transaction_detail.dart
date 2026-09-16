import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/models/finance.dart';
import '../../core/widgets/common.dart';
import '../../data/repositories/workspace.dart';

class TransactionDetail extends ConsumerStatefulWidget {
  final String id;
  const TransactionDetail(this.id, {super.key});
  @override
  ConsumerState<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends ConsumerState<TransactionDetail> {
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceProvider);
    final matches = state.transactions.where((t) => t.id == widget.id);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Transaction unavailable.')),
      );
    }
    final transaction = matches.first;
    final match = evaluateMatch(transaction, transaction.document);
    final canApprove =
        transaction.document != null &&
        ![
          ReconciliationStatus.amountMismatch,
          ReconciliationStatus.duplicateCandidate,
          ReconciliationStatus.missingDocument,
        ].contains(match.status);
    return Scaffold(
      appBar: AppBar(title: const Text('Review transaction')),
      body: PageBody(
        children: [
          const Notice('Demo data · Decisions affect this session only.'),
          Text(
            transaction.merchant,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            money(transaction.amountPence),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          StatusBadge(transaction.status),
          Text('${transaction.reference} · ${transaction.category}'),
          const SizedBox(height: 20),
          Text(
            'Supporting evidence',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (transaction.document != null)
            Notice(
              'Document ${transaction.document!.id}\n${transaction.document!.supplier} · ${money(transaction.document!.amountPence)}\nReference: ${transaction.document!.reference.isEmpty ? 'Missing' : transaction.document!.reference}',
            ),
          ...match.reasons.map(
            (r) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.rule),
              title: Text(r),
            ),
          ),
          Text(
            'Match confidence: ${(match.confidence * 100).round()}% · A signal to review, not a guarantee.',
          ),
          const SizedBox(height: 20),
          if (transaction.status != ReconciliationStatus.reconciled) ...[
            if (canApprove)
              FilledButton(
                onPressed: busy
                    ? null
                    : () async {
                        setState(() => busy = true);
                        await state.refreshPlan();
                        final success = await state.approve(widget.id);
                        if (!mounted) {
                          return;
                        }
                        setState(() => busy = false);
                        if (!success && context.mounted) {
                          context.push('/subscriptions');
                        }
                      },
                child: Text(busy ? 'Checking…' : 'Approve match'),
              ),
            if (!canApprove)
              const Notice(
                'Resolve the missing or conflicting evidence before approving this match.',
              ),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: busy ? null : () => state.reject(widget.id),
                  child: const Text('Reject'),
                ),
                TextButton(
                  onPressed: busy ? null : () => state.exception(widget.id),
                  child: const Text('Mark as exception'),
                ),
              ],
            ),
            if (transaction.document != null)
              OutlinedButton(
                onPressed: () async {
                  final targets = state.transactions
                      .where(
                        (t) =>
                            t.id != widget.id &&
                            t.document == null &&
                            t.status != ReconciliationStatus.reconciled,
                      )
                      .toList();
                  final target = await showDialog<String>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const Text('Choose another transaction'),
                      children: [
                        if (targets.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('No transactions without a document.'),
                          ),
                        ...targets.map(
                          (t) => SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, t.id),
                            child: Text(
                              '${t.merchant} · ${money(t.amountPence)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (target != null) {
                    state.chooseTransaction(widget.id, target);
                    if (context.mounted) {
                      context.replace('/transaction/$target');
                    }
                  }
                },
                child: const Text('Choose another transaction'),
              ),
          ],
          const SizedBox(height: 26),
          Text('Audit timeline', style: Theme.of(context).textTheme.titleLarge),
          ...transaction.audit.reversed.map(
            (event) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history),
              title: Text(event.summary),
              subtitle: Text(
                '${DateFormat('HH:mm').format(event.timestamp)} · ${event.actorLabel} · ${event.actorType}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
