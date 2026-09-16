import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/workspace.dart';
import '../../core/widgets/common.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workspaceProvider);
    if (!state.demo) {
      final data = state.liveDashboard;
      final company = data?['company'] as Map?;
      final overview = data?['overview'] as Map?;
      return PageBody(
        children: [
          Text(
            'Your Cherry account',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const Notice(
            'Live account overview. Bank balances and reconciliation are not connected in this mobile build.',
          ),
          if (state.busy) const Center(child: CircularProgressIndicator()),
          if (state.error.isNotEmpty) Notice(state.error),
          if (data != null) ...[
            Text(
              '${company?['company_name'] ?? 'Your business'}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Card(
              child: ListTile(
                title: const Text('Invoices'),
                trailing: Text('${overview?['invoice'] ?? 0}'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Unpaid invoices'),
                trailing: Text('${overview?['unpaid_invoice'] ?? 0}'),
              ),
            ),
            ...((data['invoices'] as List?) ?? []).map(
              (i) => Card(
                child: ListTile(
                  title: Text('${i['prefix'] ?? ''}${i['invo_no'] ?? ''}'),
                  subtitle: Text(
                    '${i['first_name'] ?? ''} ${i['last_name'] ?? ''}',
                  ),
                  trailing: Text(
                    '${company?['currency'] ?? ''}${i['total_amount'] ?? ''}',
                  ),
                ),
              ),
            ),
          ],
          OutlinedButton(
            onPressed: state.busy ? null : state.loadLive,
            child: const Text('Refresh account overview'),
          ),
        ],
      );
    }
    final incoming = state.transactions
        .where((t) => t.amountPence > 0)
        .fold(0, (sum, t) => sum + t.amountPence);
    final outgoing = state.transactions
        .where((t) => t.amountPence < 0)
        .fold(0, (sum, t) => sum - t.amountPence);
    return PageBody(
      children: [
        const Text(
          'YOUR BUSINESS, IN FOCUS',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 2,
            color: Color(0xFF68636A),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A little clarity.\nA lot less admin.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF30262C),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Demo cash balance',
                style: TextStyle(color: Colors.white70),
              ),
              const Text(
                '£8,420.50',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 32,
                runSpacing: 12,
                children: [
                  Text(
                    'Money in\n${money(incoming)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Money out\n${money(outgoing)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    '${state.reconciled}\nReconciled',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    '${state.attention}\nNeed attention',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✦ CHERRY COPILOT',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: Color(0xFFAD1929),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.attention} items need a look. Start with the amount mismatch and possible duplicate.',
                ),
                TextButton(
                  onPressed: () => context.go('/reconcile'),
                  child: const Text('Review your inbox →'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => context.push('/capture'),
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('Capture receipt or invoice'),
        ),
        const SizedBox(height: 26),
        Text('Recent activity', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...state.transactions
            .take(3)
            .map(
              (t) => TransactionCard(
                t,
                onTap: () => context.push('/transaction/${t.id}'),
              ),
            ),
      ],
    );
  }
}
