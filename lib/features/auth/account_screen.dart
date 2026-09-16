import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/cherry_logo.dart';
import '../../data/repositories/workspace.dart';

class AccountScreen extends ConsumerStatefulWidget {
  final bool reset;
  const AccountScreen({super.key, this.reset = false});
  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final form = GlobalKey<FormState>();
  final fields = {
    for (final key in [
      'company_name',
      'name',
      'email',
      'country_code',
      'phone',
      'password',
      'otp',
    ])
      key: TextEditingController(),
  };
  bool accepted = false, busy = false;
  String? companyId;
  String message = '';
  @override
  void initState() {
    super.initState();
    fields['country_code']!.text = '+44';
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> run(Future<void> Function() action) async {
    setState(() {
      busy = true;
      message = '';
    });
    try {
      await action();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => message = e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => message = 'Unable to complete this request. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) {
      return;
    }
    final state = ref.read(workspaceProvider);
    await run(() async {
      if (widget.reset) {
        final result = await state.api.forgot(fields['email']!.text.trim());
        if (mounted) {
          setState(() => message = result);
        }
      } else if (companyId != null) {
        await state.api.verifyOtp(companyId!, fields['otp']!.text.trim());
        await state.acceptVerifiedSession();
        if (mounted) {
          context.go('/home');
        }
      } else {
        final id = await state.api.signup({
          for (final e in fields.entries.where((e) => e.key != 'otp'))
            e.key: e.key == 'password' ? e.value.text : e.value.text.trim(),
          'terms_accepted': accepted,
        });
        fields['password']!.clear();
        if (mounted) {
          setState(() {
            companyId = id;
            message =
                'Enter the verification code from your email. If it has not arrived, use Resend code.';
          });
        }
      }
    });
  }

  Widget field(String key, String label, {TextInputType? keyboard}) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: fields[key],
      enabled: !busy,
      decoration: InputDecoration(labelText: label),
      obscureText: key == 'password',
      keyboardType: keyboard,
      autofillHints: key == 'email'
          ? [AutofillHints.email]
          : key == 'password'
          ? [AutofillHints.newPassword]
          : null,
      inputFormatters: ['phone', 'otp'].contains(key)
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      validator: (value) {
        final v = value?.trim() ?? '';
        if (v.isEmpty) {
          return 'Enter $label';
        }
        if (key == 'email' &&
            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v)) {
          return 'Enter a valid business email';
        }
        if (key == 'password' && (value?.length ?? 0) < 6) {
          return 'Use at least 6 characters';
        }
        if (key == 'phone' && !RegExp(r'^\d{7,15}$').hasMatch(v)) {
          return 'Use 7–15 digits';
        }
        if (key == 'country_code' && !RegExp(r'^\+?\d{1,4}$').hasMatch(v)) {
          return 'Enter a calling code, e.g. +44';
        }
        if (key == 'otp' && !RegExp(r'^\d{6}$').hasMatch(v)) {
          return 'Enter the 6-digit code';
        }
        return null;
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final verifying = companyId != null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to sign in',
          onPressed: busy ? null : () => context.go('/login'),
        ),
        title: const Text('Cherry Money'),
      ),
      body: PageBody(
        children: [
          const CherryLogo(),
          const SizedBox(height: 24),
          Text(
            widget.reset
                ? 'Reset your password'
                : verifying
                ? 'Verify your email'
                : 'Create your account',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(
            widget.reset
                ? 'We will email a link to reset your password.'
                : verifying
                ? 'Check ${fields['email']!.text} for your verification code.'
                : 'Bring your business finances together with Cherry Money.',
          ),
          const SizedBox(height: 24),
          Form(
            key: form,
            child: Column(
              children: [
                if (verifying)
                  field(
                    'otp',
                    'Verification code',
                    keyboard: TextInputType.number,
                  )
                else ...[
                  if (!widget.reset) ...[
                    field('company_name', 'Company name'),
                    field('name', 'Your name'),
                  ],
                  field(
                    'email',
                    'Business email',
                    keyboard: TextInputType.emailAddress,
                  ),
                  if (!widget.reset) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: field(
                            'country_code',
                            'Country code',
                            keyboard: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: field(
                            'phone',
                            'Phone',
                            keyboard: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    field('password', 'Choose password'),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: accepted,
                      onChanged: busy
                          ? null
                          : (v) => setState(() => accepted = v ?? false),
                      title: const Text('I agree to the Terms & Conditions'),
                    ),
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => run(() async {
                              final base = Uri.parse(
                                ref
                                    .read(workspaceProvider)
                                    .api
                                    .dio
                                    .options
                                    .baseUrl,
                              );
                              if (!await launchUrl(
                                base.resolve('/term'),
                                mode: LaunchMode.externalApplication,
                              )) {
                                throw const ApiException(
                                  'Unable to open the Terms & Conditions. Please try again.',
                                );
                              }
                            }),
                      child: const Text('Read Terms & Conditions'),
                    ),
                  ],
                ],
              ],
            ),
          ),
          if (message.isNotEmpty) Notice(message),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: busy || (!widget.reset && !verifying && !accepted)
                ? null
                : submit,
            child: Text(
              busy
                  ? 'Please wait…'
                  : widget.reset
                  ? 'Send reset link'
                  : verifying
                  ? 'Verify and sign in'
                  : 'Create account',
            ),
          ),
          if (verifying)
            TextButton(
              onPressed: busy
                  ? null
                  : () => run(() async {
                      final sent = await ref
                          .read(workspaceProvider)
                          .api
                          .resendCode(companyId!);
                      if (mounted) {
                        setState(
                          () => message = sent
                              ? 'A new verification code has been sent.'
                              : 'The email could not be sent. Please retry shortly.',
                        );
                      }
                    }),
              child: const Text('Resend code'),
            ),
          TextButton(
            onPressed: busy ? null : () => context.go('/login'),
            child: const Text('Back to sign in'),
          ),
        ],
      ),
    );
  }
}
