import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/common.dart';
import '../../data/repositories/workspace.dart';
import 'live_common.dart';

class AskCherryScreen extends ConsumerStatefulWidget {
  const AskCherryScreen({super.key});
  @override
  ConsumerState<AskCherryScreen> createState() => _AskCherryScreenState();
}

class _AskCherryScreenState extends ConsumerState<AskCherryScreen> {
  final input = TextEditingController();
  bool busy = false;
  String error = '', failedMessage = '';
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> ask([String? prompt]) async {
    final message = (prompt ?? input.text).trim();
    if (busy || message.isEmpty) return;
    if (message.length > 2400) {
      setState(
        () => error = 'Please keep your question under 2,400 characters.',
      );
      return;
    }
    final workspace = ref.read(workspaceProvider);
    final generation = workspace.sessionGeneration;
    final history = List<Map<String, String>>.from(workspace.cherryHistory);
    setState(() {
      busy = true;
      error = '';
      failedMessage = message;
    });
    try {
      final result = await workspace.api.askCherry(message, history);
      final reply = text(result['reply']);
      if (reply.isEmpty) {
        throw const ApiException(
          'Ask Cherry returned an empty answer. Please retry.',
        );
      }
      if (!mounted ||
          !workspace.signedIn ||
          generation != workspace.sessionGeneration) {
        return;
      }
      setState(() {
        workspace.cherryHistory.addAll([
          {'role': 'user', 'content': message},
          {'role': 'assistant', 'content': reply},
        ]);
        input.clear();
        failedMessage = '';
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(workspaceProvider).cherryHistory;
    return PageBody(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Ask Cherry',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            IconButton(
              tooltip: 'Clear conversation',
              onPressed: busy
                  ? null
                  : () => setState(() {
                      history.clear();
                      error = '';
                      failedMessage = '';
                    }),
              icon: const Icon(Icons.add_comment_outlined),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Answers from your Cherry Money records. Help with the next step.',
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final action in <(String, String, IconData)>[
              ('Create invoice', 'invoice', Icons.receipt_long_outlined),
              ('Create quote', 'quote', Icons.request_quote_outlined),
              ('Add expense', 'expense', Icons.add_card_outlined),
              ('Scan receipt', 'scan', Icons.document_scanner_outlined),
              ('Supplier bill', 'purchase_invoice', Icons.inventory_2_outlined),
              ('VAT preview', 'vat', Icons.calculate_outlined),
              ('Payment draft', 'payment-draft', Icons.edit_note_outlined),
            ])
              ActionChip(
                avatar: Icon(action.$3, size: 18),
                label: Text(action.$1),
                onPressed: () => context.push('/create/${action.$2}'),
              ),
            ActionChip(
              avatar: const Icon(Icons.fact_check_outlined, size: 18),
              label: const Text('Reconcile'),
              onPressed: () => context.go('/reconcile'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (history.isEmpty) ...[
          for (final prompt in [
            'Which invoices are overdue?',
            'What needs my attention?',
            'Summarise my expenses this month.',
            'Explain my recent bank transactions.',
            'What is included in my VAT figures?',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: busy ? null : () => ask(prompt),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(prompt),
                  ),
                ),
              ),
            ),
        ],
        for (final entry in history)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Align(
              alignment: entry['role'] == 'user'
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: entry['role'] == 'user'
                      ? const Color(0xFFF0E5E8)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['role'] == 'user' ? 'You' : 'Ask Cherry',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SelectionArea(child: Text(entry['content'] ?? '')),
                  ],
                ),
              ),
            ),
          ),
        if (busy)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Ask Cherry is checking your records…'),
              ],
            ),
          ),
        if (error.isNotEmpty) ...[
          Notice(error),
          TextButton(
            onPressed: busy ? null : () => ask(failedMessage),
            child: const Text('Retry question'),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: input,
          enabled: !busy,
          minLines: 2,
          maxLines: 6,
          maxLength: 2400,
          decoration: const InputDecoration(
            labelText: 'Ask about your business',
            hintText: 'For example: Which invoices need chasing?',
          ),
        ),
        FilledButton.icon(
          onPressed: busy ? null : () => ask(),
          icon: const Icon(Icons.arrow_upward),
          label: const Text('Ask Cherry'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Review important figures against the original records. Use the guided actions above to create records; chat replies do not execute payments or send emails.',
        ),
        TextButton.icon(
          onPressed: () => openCherry(context, 'ai'),
          icon: const Icon(Icons.open_in_new),
          label: const Text('Open full Ask Cherry workspace'),
        ),
      ],
    );
  }
}
