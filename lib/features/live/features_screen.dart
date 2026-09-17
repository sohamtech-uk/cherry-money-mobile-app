import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/common.dart';
import '../../data/repositories/workspace.dart';
import 'live_common.dart';

const nativeFeatures = <(String, String, IconData, String)>[
  (
    'Invoices',
    'View invoices, create drafts and download PDFs',
    Icons.receipt_long_outlined,
    '/records/invoice',
  ),
  (
    'Expenses',
    'Capture receipts and review expense records',
    Icons.document_scanner_outlined,
    '/records/expense',
  ),
  (
    'Quotes',
    'Prepare and review customer quotations',
    Icons.request_quote_outlined,
    '/records/quote',
  ),
  (
    'Clients',
    'Your customer directory and balances',
    Icons.people_outline,
    '/records/client',
  ),
  (
    'Products & services',
    'Your catalogue and prices',
    Icons.inventory_2_outlined,
    '/records/product',
  ),
  (
    'Payments',
    'Recorded invoice payments',
    Icons.payments_outlined,
    '/records/payment',
  ),
  (
    'Recurring invoices',
    'Review recurring billing',
    Icons.event_repeat_outlined,
    '/records/rec',
  ),
  (
    'Bank accounts',
    'Connected accounts and transactions',
    Icons.account_balance_outlined,
    '/transactions',
  ),
  (
    'Reconciliation',
    'Review evidence and approve matches',
    Icons.fact_check_outlined,
    '/reconcile',
  ),
  (
    'Ask Cherry',
    'Ask questions and start guided finance tasks',
    Icons.auto_awesome_outlined,
    '/ask-cherry',
  ),
];
const webFeatures = <(String, String, String)>[
  ('Connect a bank', 'Authorise a bank connection', 'linkBank'),
  ('Purchase invoices', 'Supplier bills and approvals', 'purchase-invoice'),
  ('Sales credit notes', 'Customer credits', 'sales-credit-note'),
  ('Purchase credit notes', 'Supplier credits', 'purchase-credit-note'),
  ('VAT & HMRC', 'VAT periods, returns and submission', 'fillVat'),
  (
    'Accounting reports',
    'Profit and loss, balance sheet and trial balance',
    'accounting-reports',
  ),
  ('Cash-flow forecast', 'Plan future cash movements', 'cash-flow-forecast'),
  ('Budgets', 'Plan and review budgets', 'budgets'),
  ('Chart of accounts', 'Account codes and mappings', 'chart-of-accounts'),
  (
    'Opening balances',
    'Set your accounting starting point',
    'opening-balances',
  ),
  (
    'Accounting controls',
    'Journals, approvals and closed periods',
    'accounting-controls',
  ),
  ('Ledger reconciliation', 'Review ledger balances', 'ledger-reconciliation'),
  ('Cherry Pay', 'Payment services and marketplace', 'cherry-pay'),
  ('Team & permissions', 'Manage user access', 'user'),
  ('Business settings', 'Company, tax and account configuration', 'setting'),
];

class FeaturesScreen extends ConsumerWidget {
  const FeaturesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(workspaceProvider).demo;
    return PageBody(
      children: [
        Text(
          'Your business toolkit',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        const Text('Everything you need to keep business moving.'),
        const SizedBox(height: 20),
        if (demo)
          const Notice(
            'Sign in to use live finance features. Your demo stays separate from your real account.',
          ),
        for (final feature in nativeFeatures)
          Card(
            child: ListTile(
              leading: Icon(feature.$3),
              title: Text(feature.$1),
              subtitle: Text(feature.$2),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(
                demo && feature.$4.startsWith('/records')
                    ? '/login'
                    : feature.$4,
              ),
            ),
          ),
        const SizedBox(height: 24),
        Text(
          'More in Cherry Money',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'These features open securely on the Cherry Money website. Sign in there if prompted. Availability follows your plan and permissions.',
          ),
        ),
        for (final feature in webFeatures)
          ListTile(
            title: Text(feature.$1),
            subtitle: Text(feature.$2),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => openCherry(context, feature.$3),
          ),
      ],
    );
  }
}
