import '../live/banking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/finance.dart';
import '../../core/widgets/common.dart';
import '../../data/repositories/workspace.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});
  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String query = '';
  ReconciliationStatus? filter;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceProvider);
    if (!state.demo) {
      return const BankingScreen();
    }
    final results = state.transactions.where(
      (t) =>
          '${t.merchant} ${t.reference}'.toLowerCase().contains(
            query.toLowerCase(),
          ) &&
          (filter == null || t.status == filter),
    );
    return PageBody(
      children: [
        Text('Transactions', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 18),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search merchant or reference',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => query = v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ReconciliationStatus>(
          initialValue: filter,
          decoration: const InputDecoration(labelText: 'Status'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All statuses')),
            ...ReconciliationStatus.values.map(
              (s) => DropdownMenuItem(value: s, child: Text(s.label)),
            ),
          ],
          onChanged: (v) => setState(() => filter = v),
        ),
        const SizedBox(height: 14),
        if (results.isEmpty) const Notice('No transactions match your search.'),
        ...results.map(
          (t) => TransactionCard(
            t,
            onTap: () => context.push('/transaction/${t.id}'),
          ),
        ),
      ],
    );
  }
}
