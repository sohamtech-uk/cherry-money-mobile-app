import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/workspace.dart';
import '../../core/widgets/common.dart';
import 'finance_overview.dart';
import '../live/live_common.dart';

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
          const SizedBox(height: 8),
          const Text('Your business, all in one place.'),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.push('/create/scan'),
            icon: const Icon(Icons.document_scanner_outlined),
            label: const Text('Scan an expense receipt'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('New invoice'),
                onPressed: () => context.push('/create/invoice'),
              ),
              ActionChip(
                avatar: const Icon(Icons.auto_awesome_outlined, size: 18),
                label: const Text('Ask Cherry'),
                onPressed: () => context.go('/ask-cherry'),
              ),
              ActionChip(
                avatar: const Icon(Icons.grid_view_outlined, size: 18),
                label: const Text('All features'),
                onPressed: () => context.go('/features'),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
                onTap: () => context.push('/records/invoice'),
                trailing: Text('${overview?['invoice'] ?? 0}'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Unpaid invoices'),
                onTap: () => context.push('/records/invoice'),
                trailing: Text('${overview?['unpaid_invoice'] ?? 0}'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.document_scanner_outlined),
                title: const Text('Expenses'),
                subtitle: const Text('Receipts, costs and VAT'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/records/expense'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.request_quote_outlined),
                title: const Text('Quotes and clients'),
                subtitle: const Text('Keep your sales moving'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/records/quote'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Recent invoices',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...((data['invoices'] as List?) ?? []).map(
              (i) => Card(
                child: ListTile(
                  title: Text('${i['prefix'] ?? ''}${i['invo_no'] ?? ''}'),
                  onTap: () => context.push('/records/invoice'),
                  subtitle: Text(
                    '${i['first_name'] ?? ''} ${i['last_name'] ?? ''}',
                  ),
                  trailing: Text(
                    currencyMoney(
                      i['total_amount'],
                      text(company?['currency'], 'GBP'),
                    ),
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
        FinanceOverview(incoming: incoming, outgoing: outgoing),
        const SizedBox(height: 12),
        ReviewProgress(
          reviewed: state.reconciled,
          total: state.transactions.length,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ASK CHERRY',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: Color(0xFFAD1929),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.attention == 0
                      ? 'You’re up to date. Every demo transaction has been reviewed.'
                      : '${state.attention} items need a look. Review suggested matches and resolve missing or conflicting evidence.',
                ),
                TextButton(
                  onPressed: () => context.go('/reconcile'),
                  child: const Text('Review your inbox'),
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
