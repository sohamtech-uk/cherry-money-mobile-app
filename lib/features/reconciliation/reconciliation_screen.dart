import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/finance.dart';
import '../../core/widgets/common.dart';
import '../../data/repositories/workspace.dart';

class ReconciliationScreen extends ConsumerWidget {
  const ReconciliationScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workspaceProvider);
    if (!state.demo) {
      return const PageBody(
        children: [
          Notice(
            'Live reconciliation is not connected. No changes will be made to your account. Try demo from Settings.',
          ),
        ],
      );
    }
    final groups = <String, List<ReconciliationStatus>>{
      'Ready to review': [
        ReconciliationStatus.suggestedMatch,
        ReconciliationStatus.matched,
      ],
      'Needs review': [ReconciliationStatus.needsReview],
      'Missing document': [ReconciliationStatus.missingDocument],
      'Possible duplicate': [ReconciliationStatus.duplicateCandidate],
      'Amount mismatch': [ReconciliationStatus.amountMismatch],
      'Reconciled': [ReconciliationStatus.reconciled],
    };
    return PageBody(
      children: [
        Text(
          'Only what needs you.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        const Text(
          'Suggested matches explain their evidence. You make the final decision.',
        ),
        const SizedBox(height: 18),
        for (final group in groups.entries) ...[
          if (state.transactions.any(
            (t) => group.value.contains(t.status),
          )) ...[
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 8),
              child: Text(
                group.key,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...state.transactions
                .where((t) => group.value.contains(t.status))
                .map(
                  (t) => TransactionCard(
                    t,
                    onTap: () => context.push('/transaction/${t.id}'),
                  ),
                ),
          ],
        ],
      ],
    );
  }
}
