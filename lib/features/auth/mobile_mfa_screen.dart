import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MobileMfaScreen extends StatefulWidget {
  final bool busy;
  final String error;
  final Future<void> Function(String code) onVerify;
  final VoidCallback onCancel;

  const MobileMfaScreen({
    super.key,
    required this.busy,
    required this.error,
    required this.onVerify,
    required this.onCancel,
  });

  @override
  State<MobileMfaScreen> createState() => _MobileMfaScreenState();
}

class _MobileMfaScreenState extends State<MobileMfaScreen> {
  final _code = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.busy || !(_form.currentState?.validate() ?? false)) return;
    await widget.onVerify(_code.text);
    if (mounted) _code.clear();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !widget.busy) widget.onCancel();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify your sign-in'),
          leading: IconButton(
            tooltip: 'Back to sign-in',
            onPressed: widget.busy ? null : widget.onCancel,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Enter the six-digit code from your authenticator app.',
              ),
              const SizedBox(height: 20),
              Form(
                key: _form,
                child: TextFormField(
                  controller: _code,
                  autofocus: true,
                  enabled: !widget.busy,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  autocorrect: false,
                  enableSuggestions: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Authenticator code',
                  ),
                  validator: (value) => RegExp(r'^\d{6}$').hasMatch(value ?? '')
                      ? null
                      : 'Enter the six-digit code',
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              if (widget.error.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  widget.error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: widget.busy ? null : _submit,
                child: Text(widget.busy ? 'Verifying…' : 'Verify and sign in'),
              ),
              TextButton(
                onPressed: widget.busy ? null : widget.onCancel,
                child: const Text('Cancel sign-in'),
              ),
              const SizedBox(height: 16),
              const Text(
                'This request expires after five minutes. If you have lost access to your authenticator, use account recovery on the Cherry Money website.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
