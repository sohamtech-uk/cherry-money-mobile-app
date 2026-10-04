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
      if (state.liveFinance == null && !state.financeBusy) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(workspaceProvider).loadFinance();
        });
      }
      return _LiveBusinessPulse(state: state);
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


class _LiveBusinessPulse extends StatelessWidget {
  final Workspace state;

  const _LiveBusinessPulse({required this.state});

  @override
  Widget build(BuildContext context) {
    final dashboard = object(state.liveDashboard);
    final dashboardCompany = object(dashboard['company']);
    final overview = object(dashboard['overview']);
    final finance = object(state.liveFinance);
    final financeCompany = object(finance['company']);
    final accounts = records(finance['accounts']);
    final transactions = records(finance['transactions']);
    final invoices = records(finance['invoices']);
    final cashFlow = object(finance['cashFlow']);
    final commitments = records(cashFlow['upcomingCommitments']);
    final horizons = records(cashFlow['horizons']);
    final currency = text(
      financeCompany['currency'],
      text(dashboardCompany['currency'], 'GBP'),
    );

    final accountValues = accounts
        .map((account) =>
            _optionalNumber(account['available']) ??
            _optionalNumber(account['balance']))
        .whereType<double>()
        .toList();
    final connectedCash = accountValues.isEmpty
        ? null
        : accountValues.fold<double>(0, (sum, value) => sum + value);

    final moneyIn = transactions
        .where((row) => text(row['direction']) == 'credit')
        .fold<double>(0, (sum, row) => sum + number(row['amount']));
    final moneyOut = transactions
        .where((row) => text(row['direction']) == 'debit')
        .fold<double>(0, (sum, row) => sum + number(row['amount']));
    final reviewCount = transactions
        .where((row) =>
            !{'matched', 'ignored'}.contains(text(row['status'])))
        .length;
    final openInvoiceAmount = invoices
        .where((row) => text(row['status']) != 'paid')
        .fold<double>(0, (sum, row) => sum + number(row['outstanding']));
    final overdueCount = invoices.where((row) {
      if (text(row['status']) == 'paid') return false;
      final due = DateTime.tryParse(text(row['dueDate']));
      return due != null && due.isBefore(DateTime.now());
    }).length;
    final repeats = _repeatDebitPatterns(transactions);

    Map<String, dynamic> horizon(int days) => horizons.firstWhere(
          (row) => number(row['days']).round() == days,
          orElse: () => <String, dynamic>{},
        );
    final horizon30 = horizon(30);
    final forecastAvailable = cashFlow['available'] == true;
    final openingCash = _optionalNumber(cashFlow['openingCash']);
    final primaryCash = connectedCash ?? openingCash;
    final thirtyDayBalance = _optionalNumber(horizon30['closingBalance']);
    final lowestBalance = _optionalNumber(cashFlow['lowestBalance']);
    final knownOutflows30 = _optionalNumber(cashFlow['knownOutflows30']);
    final pulseStatus = forecastAvailable
        ? text(cashFlow['status'], 'healthy')
        : 'building';

    return PageBody(
      children: [
        const Text(
          'BUSINESS PULSE',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 2,
            color: Color(0xFF68636A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text(
            financeCompany['name'],
            text(dashboardCompany['company_name'], 'Your business'),
          ),
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 6),
        const Text(
          'Cash, commitments and what needs your attention — in one place.',
        ),
        const SizedBox(height: 18),
        _PulseHero(
          currency: currency,
          primaryCash: primaryCash,
          moneyIn: moneyIn,
          moneyOut: moneyOut,
          thirtyDayBalance: thirtyDayBalance,
          pulseStatus: pulseStatus,
          forecastAvailable: forecastAvailable,
        ),
        const SizedBox(height: 14),
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
              avatar: const Icon(Icons.document_scanner_outlined, size: 18),
              label: const Text('Scan expense'),
              onPressed: () => context.push('/create/scan'),
            ),
            ActionChip(
              avatar: const Icon(Icons.auto_awesome_outlined, size: 18),
              label: const Text('Ask Cherry'),
              onPressed: () => context.go('/ask-cherry'),
            ),
          ],
        ),
        if (state.financeBusy) ...[
          const SizedBox(height: 18),
          const LinearProgressIndicator(),
        ],
        if (state.error.isNotEmpty) ...[
          const SizedBox(height: 14),
          Notice(state.error),
        ],
        if (state.financeError.isNotEmpty) ...[
          const SizedBox(height: 14),
          Notice(state.financeError),
        ],
        const SizedBox(height: 22),
        Text('What needs attention', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        _PulseSignals(
          currency: currency,
          reviewCount: reviewCount,
          overdueCount: overdueCount,
          openInvoiceAmount: openInvoiceAmount,
          forecastAvailable: forecastAvailable,
          pulseStatus: pulseStatus,
          lowestBalance: lowestBalance,
          knownOutflows30: knownOutflows30,
          repeatCount: repeats.length,
          onTransactions: () => context.go('/transactions'),
          onInvoices: () => context.push('/records/invoice'),
          onForecast: () => openCherry(context, '/cash-flow-forecast'),
        ),
        const SizedBox(height: 22),
        _ForecastCard(
          currency: currency,
          cashFlow: cashFlow,
          commitments: commitments,
          onForecast: () => openCherry(context, '/cash-flow-forecast'),
          onBudgets: () => openCherry(context, '/budgets'),
        ),
        const SizedBox(height: 22),
        _RecurringSpendCard(
          currency: currency,
          patterns: repeats,
          onOpenTransactions: () => context.go('/transactions'),
        ),
        const SizedBox(height: 22),
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
                const Text(
                  'Turn the Pulse into an answer — without leaving your finance workspace.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Why did costs rise?'),
                      onPressed: () => context.go('/ask-cherry'),
                    ),
                    ActionChip(
                      label: const Text('Can I afford a purchase?'),
                      onPressed: () => context.go('/ask-cherry'),
                    ),
                    ActionChip(
                      label: const Text('What needs paying next?'),
                      onPressed: () => context.go('/ask-cherry'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Business records', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Invoices'),
            subtitle: Text(
              '${overview['unpaid_invoice'] ?? 0} unpaid · ${currencyMoney(openInvoiceAmount, currency)} outstanding',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/records/invoice'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.document_scanner_outlined),
            title: const Text('Expenses'),
            subtitle: const Text('Receipts, costs and VAT evidence'),
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
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: state.busy || state.financeBusy
              ? null
              : () async {
                  await Future.wait([state.loadLive(), state.loadFinance()]);
                },
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Refresh Business Pulse'),
        ),
      ],
    );
  }
}

class _PulseHero extends StatelessWidget {
  final String currency;
  final double? primaryCash;
  final double moneyIn;
  final double moneyOut;
  final double? thirtyDayBalance;
  final String pulseStatus;
  final bool forecastAvailable;

  const _PulseHero({
    required this.currency,
    required this.primaryCash,
    required this.moneyIn,
    required this.moneyOut,
    required this.thirtyDayBalance,
    required this.pulseStatus,
    required this.forecastAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (pulseStatus) {
      'attention' => 'Attention',
      'watch' => 'Watch',
      'healthy' => 'Healthy',
      _ => 'Building view',
    };
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF412732), Color(0xFF211F2C)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monitor_heart_outlined,
                color: Color(0xFFE9CCD4),
                size: 20,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Business financial health',
                  style: TextStyle(color: Color(0xFFE9CCD4)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            primaryCash == null
                ? 'Connect banking to see cash'
                : currencyMoney(primaryCash, currency),
            style: const TextStyle(
              fontSize: 36,
              letterSpacing: -1,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Connected / opening cash snapshot',
            style: TextStyle(color: Color(0xFFC7BCC4), fontSize: 12),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1, color: Color(0xFF61505A)),
          ),
          Wrap(
            spacing: 24,
            runSpacing: 14,
            children: [
              _PulseMetric(
                label: 'Money in',
                value: currencyMoney(moneyIn, currency),
              ),
              _PulseMetric(
                label: 'Money out',
                value: currencyMoney(moneyOut, currency),
              ),
              _PulseMetric(
                label: '30-day forecast',
                value: forecastAvailable && thirtyDayBalance != null
                    ? currencyMoney(thirtyDayBalance, currency)
                    : 'Not available',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseMetric extends StatelessWidget {
  final String label;
  final String value;

  const _PulseMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 126,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFFC7BCC4), fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
}

class _PulseSignals extends StatelessWidget {
  final String currency;
  final int reviewCount;
  final int overdueCount;
  final double openInvoiceAmount;
  final bool forecastAvailable;
  final String pulseStatus;
  final double? lowestBalance;
  final double? knownOutflows30;
  final int repeatCount;
  final VoidCallback onTransactions;
  final VoidCallback onInvoices;
  final VoidCallback onForecast;

  const _PulseSignals({
    required this.currency,
    required this.reviewCount,
    required this.overdueCount,
    required this.openInvoiceAmount,
    required this.forecastAvailable,
    required this.pulseStatus,
    required this.lowestBalance,
    required this.knownOutflows30,
    required this.repeatCount,
    required this.onTransactions,
    required this.onInvoices,
    required this.onForecast,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _SignalTile(
            icon: Icons.fact_check_outlined,
            title: reviewCount == 0
                ? 'Bank activity is reviewed'
                : '$reviewCount bank items need review',
            subtitle: reviewCount == 0
                ? 'No loaded bank rows are waiting for reconciliation.'
                : 'Match, ignore or approve transactions before month-end.',
            onTap: onTransactions,
          ),
          _SignalTile(
            icon: Icons.schedule_outlined,
            title: overdueCount == 0
                ? 'No overdue invoices in the loaded set'
                : '$overdueCount overdue invoice${overdueCount == 1 ? '' : 's'}',
            subtitle:
                '${currencyMoney(openInvoiceAmount, currency)} total unpaid invoice balance.',
            onTap: onInvoices,
          ),
          _SignalTile(
            icon: Icons.timeline_outlined,
            title: forecastAvailable
                ? 'Cash-flow outlook: ${pulseStatus == 'healthy' ? 'healthy' : pulseStatus}'
                : 'Build your cash-flow outlook',
            subtitle: forecastAvailable
                ? 'Known 30-day outflows: ${currencyMoney(knownOutflows30 ?? 0, currency)}'
                    '${lowestBalance == null ? '' : ' · lowest projected balance ${currencyMoney(lowestBalance, currency)}'}'
                : 'Cherry will use invoices, approved bills, payroll, VAT and planned items when available.',
            onTap: onForecast,
          ),
          _SignalTile(
            icon: Icons.repeat_rounded,
            title: repeatCount == 0
                ? 'No repeat debit pattern confirmed'
                : '$repeatCount repeat debit pattern${repeatCount == 1 ? '' : 's'} detected',
            subtitle:
                'Use these as a review cue for subscriptions and recurring business costs — not as an automatic cancellation list.',
            onTap: onTransactions,
          ),
        ],
      );
}

class _SignalTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SignalTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}

class _ForecastCard extends StatelessWidget {
  final String currency;
  final Map<String, dynamic> cashFlow;
  final List<Map<String, dynamic>> commitments;
  final VoidCallback onForecast;
  final VoidCallback onBudgets;

  const _ForecastCard({
    required this.currency,
    required this.cashFlow,
    required this.commitments,
    required this.onForecast,
    required this.onBudgets,
  });

  @override
  Widget build(BuildContext context) {
    final available = cashFlow['available'] == true;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cash flow & commitments',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            const Text(
              'A planning estimate from posted cash and known business obligations. It is not a promise of future cash.',
            ),
            const SizedBox(height: 14),
            if (!available)
              const Notice(
                'The governed forecast is not available yet. You can still review banking activity and build the forecast in Cherry Money.',
              )
            else if (commitments.isEmpty)
              const Text('No upcoming outflow commitments are currently loaded.')
            else
              ...commitments.take(4).map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.event_note_outlined),
                      title: Text(text(item['label'], 'Known commitment')),
                      subtitle: Text(
                        '${text(item['date'])} · ${text(item['source'], 'forecast')}',
                      ),
                      trailing: Text(
                        currencyMoney(item['amount'], currency),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onForecast,
                  icon: const Icon(Icons.timeline_outlined),
                  label: const Text('Full forecast'),
                ),
                OutlinedButton.icon(
                  onPressed: onBudgets,
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: const Text('Budgets'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecurringSpendCard extends StatelessWidget {
  final String currency;
  final List<_RepeatSpend> patterns;
  final VoidCallback onOpenTransactions;

  const _RecurringSpendCard({
    required this.currency,
    required this.patterns,
    required this.onOpenTransactions,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recurring costs & subscriptions',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 5),
              const Text(
                'Cherry flags repeat debit patterns for review. A repeat pattern is not proof of an active subscription.',
              ),
              const SizedBox(height: 12),
              if (patterns.isEmpty)
                const Text(
                  'No merchant appears at least twice in the loaded debit history.',
                )
              else
                ...patterns.take(4).map(
                      (pattern) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const Icon(Icons.repeat_one_rounded),
                        title: Text(pattern.merchant),
                        subtitle: Text('${pattern.count} loaded debits'),
                        trailing: Text(
                          'avg ${currencyMoney(pattern.average, currency)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
              TextButton.icon(
                onPressed: onOpenTransactions,
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('Review transactions'),
              ),
            ],
          ),
        ),
      );
}

class _RepeatSpend {
  final String merchant;
  final int count;
  final double average;

  const _RepeatSpend({
    required this.merchant,
    required this.count,
    required this.average,
  });
}

List<_RepeatSpend> _repeatDebitPatterns(
  List<Map<String, dynamic>> transactions,
) {
  final grouped = <String, List<Map<String, dynamic>>>{};
  for (final row in transactions) {
    if (text(row['direction']) != 'debit') continue;
    final merchant = text(row['merchant'], text(row['description'])).trim();
    if (merchant.isEmpty) continue;
    grouped.putIfAbsent(merchant.toLowerCase(), () => []).add(row);
  }

  final patterns = <_RepeatSpend>[];
  for (final rows in grouped.values) {
    if (rows.length < 2) continue;
    final total =
        rows.fold<double>(0, (sum, row) => sum + number(row['amount']));
    patterns.add(
      _RepeatSpend(
        merchant: text(rows.first['merchant'], text(rows.first['description'])),
        count: rows.length,
        average: total / rows.length,
      ),
    );
  }
  patterns.sort((a, b) {
    final byCount = b.count.compareTo(a.count);
    return byCount != 0 ? byCount : b.average.compareTo(a.average);
  });
  return patterns;
}

double? _optionalNumber(dynamic value) {
  if (value == null || text(value).trim().isEmpty) return null;
  return num.tryParse(text(value).replaceAll(',', ''))?.toDouble();
}
