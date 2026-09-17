import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/common.dart';
import '../../data/repositories/workspace.dart';
import 'live_common.dart';

class FinanceForm extends ConsumerStatefulWidget {
  final String kind;
  const FinanceForm(this.kind, {super.key});
  @override
  ConsumerState<FinanceForm> createState() => _FinanceFormState();
}

class _FinanceFormState extends ConsumerState<FinanceForm> {
  final form = GlobalKey<FormState>();
  final fields = <String, TextEditingController>{};
  Map<String, dynamic> options = {}, result = {};
  String error = '',
      currency = 'GBP',
      client = '',
      product = '',
      filename = '',
      scanNote = '';
  bool busy = false, loading = false, newClient = true, newProduct = true;
  Uint8List? image;
  String get kind => widget.kind == 'scan' ? 'expense' : widget.kind;
  bool get sale => ['invoice', 'quote'].contains(kind);
  bool get expense => ['expense', 'purchase_invoice'].contains(kind);
  TextEditingController field(String name, [String initial = '']) =>
      fields.putIfAbsent(name, () => TextEditingController(text: initial));
  String value(String name) => field(name).text.trim();
  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    field('date_added', DateFormat('yyyy-MM-dd').format(today));
    field(
      'due_date',
      DateFormat('yyyy-MM-dd').format(today.add(const Duration(days: 7))),
    );
    field(
      'start_date',
      DateFormat('yyyy-MM-dd').format(DateTime(today.year, today.month, 1)),
    );
    field('end_date', DateFormat('yyyy-MM-dd').format(today));
    field('qty', '1');
    field('tax_rate', '0');
    field('discount', '0');
    Future.microtask(load);
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final data = await ref
          .read(workspaceProvider)
          .api
          .financeRequest('mobile/options');
      if (mounted) {
        setState(() {
          options = data;
          currency = text(data['currency'], 'GBP');
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String? numeric(String? raw, {bool positive = false, double? max}) {
    final v = double.tryParse((raw ?? '').trim());
    return v == null ||
            !v.isFinite ||
            v < 0 ||
            (positive && v == 0) ||
            (max != null && v > max)
        ? 'Enter a valid ${positive ? 'positive ' : ''}amount${max != null ? ' up to $max' : ''}.'
        : null;
  }

  Widget input(
    String name,
    String label, {
    bool required = false,
    bool amount = false,
    bool date = false,
    double? max,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: field(name),
      enabled: !busy,
      keyboardType: amount
          ? const TextInputType.numberWithOptions(decimal: true)
          : date
          ? TextInputType.datetime
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: date ? 'YYYY-MM-DD' : null,
      ),
      validator: (raw) {
        final v = (raw ?? '').trim();
        if (required && v.isEmpty) return 'This field is required.';
        if (v.isEmpty) return null;
        if (amount) return numeric(v, positive: name == 'qty', max: max);
        if (date) {
          try {
            DateFormat('yyyy-MM-dd').parseStrict(v);
          } catch (_) {
            return 'Use YYYY-MM-DD.';
          }
        }
        if (name == 'client_email' &&
            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v)) {
          return 'Enter a valid email.';
        }
        return null;
      },
    ),
  );
  Future<void> scan(ImageSource? source) async {
    if (busy) return;
    try {
      Uint8List? bytes;
      String name;
      if (source == null) {
        final picked = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png'],
          withData: true,
        );
        if (picked == null) return;
        bytes = picked.files.single.bytes;
        name = picked.files.single.name;
      } else {
        final picked = await ImagePicker().pickImage(
          source: source,
          maxWidth: 2000,
          imageQuality: 85,
        );
        if (picked == null) return;
        bytes = await picked.readAsBytes();
        name = picked.name;
      }
      if (bytes == null || bytes.length > 5 * 1024 * 1024) {
        throw const ApiException('Choose a JPEG or PNG under 5 MB.');
      }
      if (!mounted) return;
      setState(() {
        image = bytes;
        filename = name;
        busy = true;
        error = '';
        scanNote = '';
      });
      final response = await ref
          .read(workspaceProvider)
          .api
          .financeRequest(
            'mobile/receipt/scan',
            method: 'POST',
            data: {'image': base64Encode(bytes)},
          );
      final extraction = object(response['extraction']);
      if (!mounted) return;
      setState(() {
        field('title').text = text(extraction['title']);
        field('date_added').text = text(extraction['date_added']);
        field('amount').text = extraction['net_amount'] == null
            ? ''
            : text(extraction['net_amount']);
        field('tax_rate').text = extraction['vat_amount'] == null ? '' : '0';
        if (number(extraction['net_amount']) > 0 &&
            extraction['vat_amount'] != null) {
          field('tax_rate').text =
              (number(extraction['vat_amount']) /
                      number(extraction['net_amount']) *
                      100)
                  .toStringAsFixed(2);
        }
        final receiptCurrency = text(extraction['currency']).toUpperCase();
        final accountCurrency = currency == '£'
            ? 'GBP'
            : currency.toUpperCase();
        if (receiptCurrency.isNotEmpty && receiptCurrency != accountCurrency) {
          field('amount').clear();
          field('tax_rate').clear();
        }
        scanNote =
            'Receipt total: ${currencyMoney(extraction['total_amount'], text(extraction['currency'], currency))}. ${extraction['net_amount'] == null ? 'The net amount could not be identified; enter it from the receipt. ' : ''}Review the date, net amount and VAT before saving. For a foreign-currency receipt, enter the converted amounts in your company currency. The receipt image will be attached when you save the expense.';
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Could not read the image. Try another photo or enter the expense manually.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Map<String, dynamic> payload() {
    if (sale) {
      return {
        'confirmation': true,
        'client_mode': newClient ? 'new' : 'existing',
        if (newClient) ...{
          'client_name': value('client_name'),
          'client_email': value('client_email'),
        } else
          'client_id': client,
        'product_mode': newProduct ? 'new' : 'existing',
        if (newProduct)
          'new_product': value('new_product')
        else
          'product_id': product,
        'qty': number(value('qty')),
        'price': number(value('price')),
        'tax_rate': number(value('tax_rate')),
        'tax_name': 'VAT',
        'discount_type': 1,
        'discount': number(value('discount')),
        'date_added': value('date_added'),
        'due_date': value('due_date'),
        'invoice_note': value('notes'),
      };
    }
    if (expense) {
      return {
        'confirmation': true,
        'expense_kind': kind,
        if (kind == 'expense' && image != null) 'receipt': base64Encode(image!),
        'title': value('title'),
        'supplier_name': value('title'),
        'invoice_no': value('invoice_no'),
        'amount': number(value('amount')),
        'vat_rate': number(value('tax_rate')),
        'vat_transaction_type': number(value('tax_rate')) > 0
            ? 'standard purchase'
            : 'no vat',
        'vat_recoverable': number(value('tax_rate')) > 0 ? 1 : 0,
        'date_added': value('date_added'),
        'invoice_date': value('date_added'),
        if (kind == 'purchase_invoice') 'due_date': value('due_date'),
        'category': value('category'),
        'payment_method': value('payment_method').isEmpty
            ? 'Other'
            : value('payment_method'),
        'notes': value('notes'),
      };
    }
    if (kind == 'vat') {
      return {'start_date': value('start_date'), 'end_date': value('end_date')};
    }
    return {
      'payee': value('payee'),
      'amount': number(value('amount')),
      'reference': value('reference'),
      'purpose': value('notes'),
    };
  }

  Future<void> submit() async {
    if (busy || !(form.currentState?.validate() ?? false)) return;
    if (sale &&
        ((!newClient && client.isEmpty) || (!newProduct && product.isEmpty))) {
      setState(() => error = 'Choose a client and product.');
      return;
    }
    final data = payload();
    if ((sale || kind == 'purchase_invoice') &&
        DateTime.parse(
          value('due_date'),
        ).isBefore(DateTime.parse(value('date_added')))) {
      setState(
        () => error = 'The due date must be on or after the issue date.',
      );
      return;
    }
    if (kind != 'vat') {
      final net = sale
          ? number(data['qty']) * number(data['price']) -
                number(data['discount'])
          : number(data['amount']);
      if (net < 0) {
        setState(() => error = 'The discount cannot exceed the subtotal.');
        return;
      }
      final total =
          net * (1 + number(data['tax_rate'] ?? data['vat_rate']) / 100);
      final confirm = await confirmAction(
        context,
        kind == 'payment-draft'
            ? 'Save payment draft?'
            : 'Save this ${kind.replaceAll('_', ' ')}?',
        '${sale ? (newClient ? value('client_name') : records(options['clients']).where((r) => text(r['id']) == client).map((r) => text(r['first_name'])).join()) : value(kind == 'payment-draft' ? 'payee' : 'title')}\nTotal: ${currencyMoney(total, currency)}\n${sale
            ? '${value('date_added')} · Due ${value('due_date')}\nThis saves a draft. No email is sent.'
            : kind == 'payment-draft'
            ? 'A draft only. No money will be moved.'
            : 'This creates a record in your live company account.'}',
        action: 'Save',
      );
      if (!confirm || !mounted) return;
    }
    setState(() {
      busy = true;
      error = '';
    });
    try {
      final path = switch (kind) {
        'payment-draft' => 'webmcp/payment-drafts',
        'vat' => 'mobile/vat/preview',
        'purchase_invoice' => 'mobile/expense',
        _ => 'mobile/$kind',
      };
      final response = await ref
          .read(workspaceProvider)
          .api
          .financeRequest(path, method: 'POST', data: data);
      if (mounted) setState(() => result = response);
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.kind) {
      'scan' => 'Scan receipt',
      'purchase_invoice' => 'Supplier bill',
      'vat' => 'VAT preview',
      'payment-draft' => 'Payment draft',
      _ => 'New ${widget.kind}',
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PageBody(
        children: [
          if (loading || busy) const LinearProgressIndicator(),
          if (error.isNotEmpty) Notice(error),
          if (options.isEmpty && !loading)
            TextButton(
              onPressed: load,
              child: const Text('Retry loading account options'),
            ),
          if (result.isNotEmpty) ...[
            const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF207151),
              size: 56,
            ),
            Notice(text(result['message'], 'Saved successfully.')),
            if (kind == 'vat') ...[
              const Text('Preview only. No VAT return has been submitted.'),
              for (final entry in object(result['boxes']).entries)
                ListTile(
                  title: Text(
                    text(object(result['box_labels'])[entry.key], entry.key),
                  ),
                  trailing: Text(text(entry.value)),
                ),
              TextButton(
                onPressed: () => openCherry(
                  context,
                  text(result['breakdown_url'], 'vatBreakdown'),
                ),
                child: const Text('Review VAT breakdown on Cherry Money'),
              ),
            ],
            if (result['preview_url'] != null)
              OutlinedButton(
                onPressed: () =>
                    openCherry(context, text(result['preview_url'])),
                child: const Text('Preview invoice'),
              ),
            if (result['download_url'] != null)
              OutlinedButton(
                onPressed: () =>
                    openCherry(context, text(result['download_url'])),
                child: const Text('Download PDF'),
              ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ] else
            Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (kind == 'expense') ...[
                    const Text(
                      'Capture a receipt, then check the details before saving. JPEG or PNG, up to 5 MB.',
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: busy
                              ? null
                              : () => scan(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Camera'),
                        ),
                        OutlinedButton.icon(
                          onPressed: busy ? null : () => scan(null),
                          icon: const Icon(Icons.upload_file_outlined),
                          label: const Text('Upload receipt'),
                        ),
                      ],
                    ),
                    if (image != null) ...[
                      Text(filename),
                      Image.memory(
                        image!,
                        height: 160,
                        errorBuilder: (_, _, _) =>
                            const Text('Image preview unavailable'),
                      ),
                    ],
                    if (scanNote.isNotEmpty) Notice(scanNote),
                  ],
                  if (sale) ...[
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: newClient,
                      onChanged: busy
                          ? null
                          : (v) => setState(() => newClient = v),
                      title: const Text('New client'),
                    ),
                    if (newClient) ...[
                      input('client_name', 'Client name', required: true),
                      input('client_email', 'Client email', required: true),
                    ] else
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: client.isEmpty ? null : client,
                        decoration: const InputDecoration(labelText: 'Client'),
                        items: records(options['clients'])
                            .map(
                              (r) => DropdownMenuItem(
                                value: text(r['id']),
                                child: Text(
                                  '${text(r['first_name'])} ${text(r['last_name'])}',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: busy
                            ? null
                            : (v) => setState(() => client = v ?? ''),
                      ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: newProduct,
                      onChanged: busy
                          ? null
                          : (v) => setState(() => newProduct = v),
                      title: const Text('New product or service'),
                    ),
                    if (newProduct)
                      input('new_product', 'Product or service', required: true)
                    else
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: product.isEmpty ? null : product,
                        decoration: const InputDecoration(labelText: 'Product'),
                        items: records(options['products'])
                            .map(
                              (r) => DropdownMenuItem(
                                value: text(r['id']),
                                child: Text(text(r['name'])),
                              ),
                            )
                            .toList(),
                        onChanged: busy
                            ? null
                            : (v) {
                                setState(() => product = v ?? '');
                                final p = records(
                                  options['products'],
                                ).where((r) => text(r['id']) == v).firstOrNull;
                                if (p != null) {
                                  field('price').text = text(p['price']);
                                }
                              },
                      ),
                    input('qty', 'Quantity', required: true, amount: true),
                    input(
                      'price',
                      'Unit price ($currency)',
                      required: true,
                      amount: true,
                    ),
                    input(
                      'discount',
                      'Discount amount ($currency)',
                      amount: true,
                    ),
                  ],
                  if (expense) ...[
                    input(
                      'title',
                      kind == 'purchase_invoice'
                          ? 'Supplier name'
                          : 'Expense title',
                      required: true,
                    ),
                    if (kind == 'purchase_invoice')
                      input('invoice_no', 'Supplier invoice number'),
                    input(
                      'amount',
                      'Net amount, before VAT ($currency)',
                      required: true,
                      amount: true,
                    ),
                    input('category', 'Category'),
                    input('payment_method', 'Payment method'),
                  ],
                  if (sale || expense) ...[
                    input(
                      'tax_rate',
                      'VAT rate (%) — use 0 for no VAT',
                      required: true,
                      amount: true,
                      max: 100,
                    ),
                    input(
                      'date_added',
                      'Issue / expense date',
                      required: true,
                      date: true,
                    ),
                    if (sale || kind == 'purchase_invoice')
                      input('due_date', 'Due date', required: true, date: true),
                    input('notes', 'Notes'),
                  ],
                  if (kind == 'vat') ...[
                    const Text(
                      'Calculate the VAT boxes from your company records. Review them before submitting a return.',
                    ),
                    input(
                      'start_date',
                      'Period start',
                      required: true,
                      date: true,
                    ),
                    input('end_date', 'Period end', required: true, date: true),
                  ],
                  if (kind == 'payment-draft') ...[
                    const Text(
                      'Prepare a draft for review. This does not execute a payment.',
                    ),
                    input('payee', 'Payee', required: true),
                    input(
                      'amount',
                      'Amount ($currency)',
                      required: true,
                      amount: true,
                    ),
                    input('reference', 'Reference'),
                    input('notes', 'Purpose'),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: busy || loading || options.isEmpty
                        ? null
                        : submit,
                    child: Text(
                      busy
                          ? 'Working…'
                          : kind == 'vat'
                          ? 'Calculate preview'
                          : 'Review and save',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
