import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/common.dart';
import '../../data/repositories/workspace.dart';
import 'live_common.dart';

const recordNames = {
  'invoice': 'Invoices',
  'expense': 'Expenses',
  'quote': 'Quotes',
  'client': 'Clients',
  'product': 'Products & services',
  'payment': 'Payments',
  'rec': 'Recurring invoices',
};

class RecordsScreen extends ConsumerStatefulWidget {
  final String kind;
  const RecordsScreen(this.kind, {super.key});
  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  List<Map<String, dynamic>> rows = [];
  String error = '', query = '', currency = 'GBP';
  bool busy = false, more = false;
  int page = 1;
  final search = TextEditingController();
  @override
  void initState() {
    super.initState();
    Future.microtask(() => load(reset: true));
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> load({bool reset = false}) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = '';
    });
    final next = reset ? 1 : page + 1;
    try {
      final result = await ref
          .read(workspaceProvider)
          .api
          .financeRequest(widget.kind, query: {'page': next, 'q': query});
      final batch = records(result['data'])
          .map(
            (r) => widget.kind == 'client'
                ? {...object(r['data']), 'balance': r['balance']}
                : r,
          )
          .toList();
      if (!mounted) return;
      setState(() {
        rows = reset ? batch : [...rows, ...batch];
        page = next;
        more = batch.length == 20;
        currency = text(
          result['currency'] ?? object(result['add'])['currency'],
          'GBP',
        );
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> create(String kind) async {
    await context.push('/create/$kind');
    if (mounted) await load(reset: true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(recordNames[widget.kind] ?? 'Records'),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: busy ? null : () => load(reset: true),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: PageBody(
      children: [
        if (['invoice', 'quote', 'expense'].contains(widget.kind)) ...[
          FilledButton.icon(
            onPressed: () => create(widget.kind),
            icon: const Icon(Icons.add),
            label: Text('New ${widget.kind}'),
          ),
          if (widget.kind == 'expense')
            OutlinedButton.icon(
              onPressed: () => create('scan'),
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Text('Scan a receipt'),
            ),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: search,
          decoration: InputDecoration(
            labelText: 'Search ${recordNames[widget.kind]?.toLowerCase()}',
            suffixIcon: IconButton(
              tooltip: 'Search',
              onPressed: busy
                  ? null
                  : () {
                      query = search.text.trim();
                      load(reset: true);
                    },
              icon: const Icon(Icons.search),
            ),
          ),
          onSubmitted: (value) {
            query = value.trim();
            load(reset: true);
          },
        ),
        const SizedBox(height: 12),
        if (busy) const LinearProgressIndicator(),
        if (error.isNotEmpty) ...[
          Notice(error),
          TextButton(
            onPressed: () => load(reset: true),
            child: const Text('Retry'),
          ),
        ],
        if (!busy && error.isEmpty && rows.isEmpty)
          const Notice(
            'No records found. New records will appear here after they are saved.',
          ),
        for (final row in rows)
          Card(
            child: ListTile(
              title: Text(recordTitle(widget.kind, row)),
              subtitle: Text(
                [
                  if (['invoice', 'quote'].contains(widget.kind))
                    '${text(row['first_name'])} ${text(row['last_name'])}'
                        .trim(),
                  if (row['date_added'] != null) text(row['date_added']),
                  if (widget.kind == 'invoice') invoiceStatus(row['status']),
                  if (widget.kind == 'expense') text(row['category']),
                  if (widget.kind == 'client') text(row['email']),
                ].where((s) => s.isNotEmpty).join(' · '),
              ),
              trailing: Text(
                currencyMoney(
                  row['total_amount'] ??
                      row['amount'] ??
                      row['price'] ??
                      row['balance'],
                  currency,
                ),
              ),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => RecordDetail(widget.kind, row, currency),
                  ),
                );
                if (mounted) load(reset: true);
              },
            ),
          ),
        if (more)
          OutlinedButton(
            onPressed: busy ? null : load,
            child: const Text('Load more'),
          ),
        if (['client', 'product', 'payment', 'rec'].contains(widget.kind))
          TextButton.icon(
            onPressed: () => openCherry(context, widget.kind),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Manage in Cherry Money'),
          ),
      ],
    ),
  );
}

class RecordDetail extends ConsumerStatefulWidget {
  final String kind, currency;
  final Map<String, dynamic> row;
  const RecordDetail(this.kind, this.row, this.currency, {super.key});
  @override
  ConsumerState<RecordDetail> createState() => _RecordDetailState();
}

class _RecordDetailState extends ConsumerState<RecordDetail> {
  Map<String, dynamic>? detail;
  String error = '';
  bool busy = false;
  @override
  void initState() {
    super.initState();
    if (['invoice', 'quote'].contains(widget.kind)) Future.microtask(load);
  }

  Future<void> load() async {
    setState(() {
      busy = true;
      error = '';
    });
    try {
      final result = await ref
          .read(workspaceProvider)
          .api
          .financeRequest(
            widget.kind == 'invoice' ? 'editInvoice' : 'editQuote',
            query: {'id': widget.row['id']},
          );
      if (mounted) setState(() => detail = result);
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final row = detail == null ? widget.row : object(detail!['data']);
    const fields = {
      'date_added': 'Date',
      'due_date': 'Due date',
      'category': 'Category',
      'email': 'Email',
      'phone': 'Phone',
      'payment_method': 'Payment method',
      'notes': 'Notes',
      'invoice_note': 'Note',
      'description': 'Description',
    };
    return Scaffold(
      appBar: AppBar(title: Text(recordTitle(widget.kind, row))),
      body: PageBody(
        children: [
          Text(
            currencyMoney(
              row['total_amount'] ??
                  row['amount'] ??
                  row['price'] ??
                  row['balance'],
              widget.currency,
            ),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          if (widget.kind == 'invoice') Text(invoiceStatus(row['status'])),
          if (busy) const LinearProgressIndicator(),
          if (error.isNotEmpty) ...[
            Notice(error),
            TextButton(onPressed: load, child: const Text('Retry')),
          ],
          for (final entry in fields.entries)
            if (text(row[entry.key]).isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.value),
                subtitle: Text(text(row[entry.key])),
              ),
          for (final item in records(detail?['items']))
            Card(
              child: ListTile(
                title: Text(text(item['name'] ?? item['product_name'], 'Item')),
                subtitle: Text('Quantity ${text(item['qty'])}'),
                trailing: Text(currencyMoney(item['price'], widget.currency)),
              ),
            ),
          if (detail?['preview_url'] is String)
            OutlinedButton.icon(
              onPressed: () => openCherry(context, detail!['preview_url']),
              icon: const Icon(Icons.preview_outlined),
              label: const Text('Preview invoice'),
            ),
          if (detail?['download_url'] is String)
            OutlinedButton.icon(
              onPressed: () => openCherry(context, detail!['download_url']),
              icon: const Icon(Icons.download),
              label: const Text('Download PDF'),
            ),
          TextButton.icon(
            onPressed: () => openCherry(context, switch (widget.kind) {
              'invoice' =>
                'invoiceView?id=${Uri.encodeComponent(text(row['id']))}',
              'quote' => 'quote/${Uri.encodeComponent(text(row['id']))}/edit',
              _ => widget.kind,
            }),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Edit and manage in Cherry Money'),
          ),
        ],
      ),
    );
  }
}
