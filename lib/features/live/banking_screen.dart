import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/common.dart';
import '../../data/repositories/workspace.dart';
import 'live_common.dart';

typedef BankAuthorizationLauncher = Future<bool> Function(Uri uri);

Future<bool> launchBankAuthorization(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.inAppBrowserView);

class BankingScreen extends ConsumerStatefulWidget {
  final bool reconcile;
  final BankAuthorizationLauncher authorizationLauncher;
  const BankingScreen({
    super.key,
    this.reconcile = false,
    this.authorizationLauncher = launchBankAuthorization,
  });
  @override
  ConsumerState<BankingScreen> createState() => _BankingScreenState();
}

class _BankingScreenState extends ConsumerState<BankingScreen>
    with WidgetsBindingObserver {
  String query = '', error = '';
  bool actionBusy = false, awaitingBankReturn = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => ref.read(workspaceProvider).loadFinance());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && awaitingBankReturn) {
      awaitingBankReturn = false;
      Future.microtask(() => ref.read(workspaceProvider).loadFinance());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> connectBank() async {
    if (actionBusy) return;
    final accepted = await confirmAction(
      context,
      'Connect a bank securely?',
      'Cherry Money will open the regulated bank approval service inside the app. You choose the bank and approve read-only account access there. Cherry Money never receives or stores your online banking password.',
      action: 'Continue securely',
    );
    if (!accepted || !mounted) return;
    setState(() {
      actionBusy = true;
      error = '';
    });
    try {
      final result = await ref
          .read(workspaceProvider)
          .api
          .financeRequest(
            'mobile/banking/connect',
            method: 'POST',
            data: {'consent': true},
          );
      final uri = Uri.tryParse(text(result['authorization_url']));
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
        throw const ApiException(
          'The banking provider did not return a secure approval link.',
        );
      }
      awaitingBankReturn = true;
      if (!await widget.authorizationLauncher(uri)) {
        awaitingBankReturn = false;
        throw const ApiException(
          'The secure bank approval screen could not be opened.',
        );
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'The secure bank connection could not be started.',
        );
      }
    } finally {
      if (mounted) setState(() => actionBusy = false);
    }
  }

  Future<void> stage(Map<String, dynamic> transaction) async {
    if (actionBusy) return;
    setState(() {
      actionBusy = true;
      error = '';
    });
    final state = ref.read(workspaceProvider);
    try {
      final fresh = await state.api.financeRequest(
        'webmcp/reconciliation/suggest',
        method: 'POST',
        data: {'transaction_id': transaction['id']},
      );
      final suggestion = object(fresh['suggestion']);
      if (!mounted) return;
      if (suggestion['ready'] != true || suggestion['ambiguous'] == true) {
        setState(
          () => error = text(
            suggestion['reason'],
            'This transaction needs further review.',
          ),
        );
        return;
      }
      final match = object(suggestion['match']);
      if (!await confirmAction(
        context,
        'Prepare this match?',
        '${text(transaction['merchant'])}\n${currencyMoney(transaction['amount'], text(transaction['currency'], 'GBP'))}\nInvoice ${text(match['invoiceNumber'])} · ${text(match['customer'])}\n\n${text(suggestion['reason'])}\n\nThis creates a proposal for review. Approval is a separate step.',
        action: 'Prepare match',
      )) {
        return;
      }
      await state.api.financeRequest(
        'webmcp/reconciliation/stage',
        method: 'POST',
        data: {
          'transaction_id': transaction['id'],
          'invoice_id': match['invoiceId'],
        },
      );
      await state.loadFinance();
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => actionBusy = false);
    }
  }

  Future<void> approve(Map<String, dynamic> proposal) async {
    if (actionBusy) return;
    final confirmed = await confirmAction(
      context,
      'Approve reconciliation?',
      '${currencyMoney(proposal['amount'], text(proposal['currency'], 'GBP'))}\n${text(proposal['reason'])}\n\nThis records an invoice payment in your ledger and marks the bank transaction as matched. It does not send money.',
      action: 'Approve match',
    );
    if (!confirmed || !mounted) return;
    setState(() {
      actionBusy = true;
      error = '';
    });
    final state = ref.read(workspaceProvider);
    try {
      await state.api.financeRequest(
        'webmcp/reconciliation/${Uri.encodeComponent(text(proposal['id']))}/approve',
        method: 'POST',
        data: {'confirmation': true},
        headers: {'X-Cherry-Human-Approval': 'confirmed'},
      );
      await state.loadFinance();
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => actionBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceProvider);
    final data = state.liveFinance;
    final transactions = records(data?['transactions'])
        .where(
          (t) =>
              (!widget.reconcile ||
                  !['matched', 'ignored'].contains(t['status'])) &&
              '${t['merchant']} ${t['description']}'.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    final approvals = records(data?['approvals']);
    final canApprove =
        object(data?['capabilities'])['humanApproveReconciliation'] == true;
    return PageBody(
      children: [
        Text(
          widget.reconcile ? 'Review and reconcile' : 'Banking',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                widget.reconcile
                    ? 'Check the evidence. You make the final decision.'
                    : 'Your connected accounts and latest bank activity.',
              ),
            ),
            IconButton(
              tooltip: 'Refresh banking',
              onPressed: state.financeBusy ? null : state.loadFinance,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        if (state.financeBusy || actionBusy) const LinearProgressIndicator(),
        if (state.financeError.isNotEmpty) ...[
          Notice(state.financeError),
          TextButton(onPressed: state.loadFinance, child: const Text('Retry')),
        ],
        if (error.isNotEmpty) Notice(error),
        if (!widget.reconcile) ...[
          for (final account in records(data?['accounts']))
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_outlined),
                title: Text(text(account['name'])),
                subtitle: Text(
                  '${text(account['status'])} · Last synced ${text(account['lastSyncedAt'], 'not yet synced')}',
                ),
                trailing: Text(
                  account['balance'] == null
                      ? 'Balance unavailable'
                      : currencyMoney(
                          account['balance'],
                          text(account['currency'], 'GBP'),
                        ),
                ),
              ),
            ),
          TextButton.icon(
            onPressed: actionBusy ? null : connectBank,
            icon: const Icon(Icons.add),
            label: const Text('Connect or manage banks'),
          ),
          const Text(
            'Bank approval opens securely inside the app and returns here automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
        if (widget.reconcile && approvals.isNotEmpty) ...[
          Text(
            'Awaiting approval',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          for (final proposal in approvals)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currencyMoney(
                        proposal['amount'],
                        text(proposal['currency'], 'GBP'),
                      ),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(text(proposal['reason'])),
                    Text('Expires ${text(proposal['expiresAt'])}'),
                    if (canApprove)
                      FilledButton(
                        onPressed: actionBusy ? null : () => approve(proposal),
                        child: const Text('Review approval'),
                      )
                    else
                      const Text(
                        'An authorised approver must confirm this match.',
                      ),
                  ],
                ),
              ),
            ),
        ],
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search bank activity',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() => query = value),
        ),
        const SizedBox(height: 16),
        if (!state.financeBusy &&
            state.financeError.isEmpty &&
            data != null &&
            transactions.isEmpty)
          Notice(
            widget.reconcile
                ? 'No transactions need review in the latest bank activity.'
                : 'No bank transactions found. Connect a bank or sync your existing connection on Cherry Money.',
          ),
        for (final transaction in transactions)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    text(transaction['merchant'], 'Bank transaction'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${transaction['direction'] == 'debit' ? '−' : '+'}${currencyMoney(transaction['amount'], text(transaction['currency'], 'GBP'))}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${text(transaction['bookingDate'])} · ${text(transaction['status']).replaceAll('_', ' ')}',
                  ),
                  if (text(transaction['description']).isNotEmpty)
                    Text(text(transaction['description'])),
                  if (widget.reconcile) ...[
                    const SizedBox(height: 10),
                    Text(text(object(transaction['suggestion'])['reason'])),
                    if (object(transaction['suggestion'])['ready'] == true &&
                        transaction['status'] != 'pending_approval')
                      OutlinedButton(
                        onPressed: actionBusy ? null : () => stage(transaction),
                        child: const Text('Review suggested match'),
                      )
                    else if (transaction['direction'] == 'debit')
                      TextButton(
                        onPressed: () => context.push('/records/expense'),
                        child: const Text('Review expense or supplier bill'),
                      ),
                  ],
                ],
              ),
            ),
          ),
        if (data != null)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Showing up to 100 latest transactions in the app.'),
          ),
      ],
    );
  }
}
