import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/app_config.dart';

List<Map<String, dynamic>> records(dynamic value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : [];
Map<String, dynamic> object(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};
String text(dynamic value, [String fallback = '']) =>
    value == null ? fallback : value.toString();
double number(dynamic value) =>
    num.tryParse(text(value).replaceAll(',', ''))?.toDouble() ?? 0;
String currencyMoney(dynamic value, [String currency = 'GBP']) =>
    NumberFormat.currency(
      locale: 'en_GB',
      symbol: currency == 'GBP' || currency == '£' ? '£' : '$currency ',
      decimalDigits: 2,
    ).format(number(value));
String recordTitle(String kind, Map<String, dynamic> row) => switch (kind) {
  'invoice' => '${text(row['prefix'])}${text(row['invo_no'], text(row['id']))}',
  'quote' =>
    '${text(row['prefix'])}${text(row['quote_no'] ?? row['qno'], text(row['id']))}',
  'client' => '${text(row['first_name'])} ${text(row['last_name'])}'.trim(),
  'product' => text(row['name'], 'Product'),
  'payment' => text(row['trans_id'], 'Payment'),
  'rec' => '${text(row['prefix'])}${text(row['invo_no'], 'Recurring invoice')}',
  _ => text(row['title'], 'Expense'),
};
String invoiceStatus(dynamic status) => switch (text(status)) {
  '0' => 'Draft',
  '1' => 'Email sent',
  '2' => 'Paid',
  _ => text(status, 'Draft'),
};

Future<bool> confirmAction(
  BuildContext context,
  String title,
  String details, {
  String action = 'Confirm',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(details)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

/// Never send a bearer token in a browser URL. Web screens use their own session.
Future<void> openCherry(BuildContext context, String path) async {
  final base = Uri.parse(const AppConfig().apiBaseUrl);
  final uri = path.startsWith('https://')
      ? Uri.parse(path)
      : base.resolve(path.startsWith('/') ? path : '/$path');
  if (uri.scheme != 'https' || uri.host != base.host) return;
  try {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Could not open');
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Cherry Money. Please try again.'),
        ),
      );
    }
  }
}
