import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/motion.dart';
import 'apple_auth_service.dart';

/// Only the backend exchange can establish an app session; this widget just
/// collects a signed Apple identity token and hands it off.
class AppleSignInControl extends StatefulWidget {
  final AppleAuthService service;
  final Future<void> Function(String token) onToken;
  final ValueChanged<bool> onBusyChanged;
  final bool disabled;

  const AppleSignInControl({
    super.key,
    this.service = const AppleAuthService(),
    required this.onToken,
    required this.onBusyChanged,
    this.disabled = false,
  });

  @override
  State<AppleSignInControl> createState() => _AppleSignInControlState();
}

class _AppleSignInControlState extends State<AppleSignInControl> {
  bool _busy = false;
  String _error = '';

  Future<void> _exchange() async {
    if (_busy || widget.disabled || !mounted) return;
    setState(() {
      _busy = true;
      _error = '';
    });
    widget.onBusyChanged(true);
    try {
      final token = await widget.service.authenticate();
      if (!mounted) return;
      await widget.onToken(token);
    } catch (error) {
      if (mounted) {
        setState(() => _error = AppleAuthService.errorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        widget.onBusyChanged(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.service.configured) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error.isNotEmpty) ...[Notice(_error), const SizedBox(height: 12)],
        if (_busy)
          Center(
            child: ActionLabel(
              busy: true,
              label: 'Continue with Apple',
              busyLabel: 'Signing in…',
            ),
          )
        else
          SignInWithAppleButton(onPressed: widget.disabled ? null : _exchange),
      ],
    );
  }
}
