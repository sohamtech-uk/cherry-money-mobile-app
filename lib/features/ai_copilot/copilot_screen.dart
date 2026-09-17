import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/finance.dart';
import '../../core/revenuecat/subscription_state.dart';
import '../../core/widgets/common.dart';
import '../../data/repositories/workspace.dart';

class CopilotScreen extends ConsumerStatefulWidget {
  const CopilotScreen({super.key});
  @override
  ConsumerState<CopilotScreen> createState() => _CopilotScreenState();
}

class _CopilotScreenState extends ConsumerState<CopilotScreen> {
  String response = '';
  bool busy = false;
  static const prompts = [
    'What needs my attention?',
    "Why wasn't this transaction reconciled?",
    'Show invoices still awaiting payment.',
    'What changed in my cash position this week?',
  ];
  Future<void> ask(int index) async {
    final state = ref.read(workspaceProvider);
    if (index == 3) {
      setState(() => busy = true);
      await state.refreshPlan();
      if (!mounted) {
        return;
      }
      setState(() => busy = false);
      if (state.plan == Plan.free && mounted) {
        context.push('/subscriptions');
        return;
      }
    }
    setState(
      () => response = switch (index) {
        0 =>
          '${state.attention} items need attention. Review the Cloud Office amount mismatch, check the duplicate-looking Paper & Co payment, then attach the missing receipts.',
        1 =>
          'Cloud Office has a £79.99 payment and an £89.99 invoice. The £10 difference prevents a match. Check the original invoice; do not approve inconsistent evidence.',
        2 =>
          state.transactions.any(
                (t) =>
                    t.id == 't1' && t.status != ReconciliationStatus.reconciled,
              )
              ? 'Demo invoice INV-1042 for £1,250 has a matching incoming payment, but the match still needs your approval. This is a reconciliation state, not proof of an unpaid balance.'
              : 'INV-1042 is reconciled in this demo session. No additional unpaid invoice evidence is available.',
        _ =>
          'Across this synthetic transaction set, income is £1,250 and outgoing transactions total £1,592.49. Net movement is −£342.49, including a possible duplicate. Review that payment before interpreting this as a final cash position.',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceProvider);
    return PageBody(
      children: [
        Text(
          'A second pair\nof eyes.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const Notice(
          'Demo Ask Cherry · Structured local responses, not a live AI service. Decision support, not financial advice.',
        ),
        if (!state.demo)
          const Notice(
            'Live Ask Cherry is not connected. Try demo from Settings.',
          ),
        if (state.demo) ...[
          ...prompts.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: busy ? null : () => ask(entry.key),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '${entry.value}${entry.key == 3 ? ' · Pro' : ''}',
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (response.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Text(response),
              ),
            ),
        ],
      ],
    );
  }
}
