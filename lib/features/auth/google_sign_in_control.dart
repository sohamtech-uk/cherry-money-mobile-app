import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/motion.dart';
import 'google_auth_service.dart';
import 'google_button_stub.dart'
    if (dart.library.js_interop) 'google_button_web.dart';

/// Owns the SDK lifecycle; only the backend exchange can establish an app session.
class GoogleSignInControl extends StatefulWidget {
  final GoogleAuthService service;
  final Future<void> Function(String token) onToken;
  final ValueChanged<bool> onBusyChanged;
  final bool disabled;

  const GoogleSignInControl({
    super.key,
    this.service = const GoogleAuthService(),
    required this.onToken,
    required this.onBusyChanged,
    this.disabled = false,
  });

  @override
  State<GoogleSignInControl> createState() => _GoogleSignInControlState();
}

class _GoogleSignInControlState extends State<GoogleSignInControl> {
  StreamSubscription<String>? _subscription;
  bool _ready = false;
  bool _busy = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    if (widget.service.configured) unawaited(_initialize());
  }

  Future<void> _initialize() async {
    setState(() => _error = '');
    try {
      await widget.service.initialize().timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (widget.service.usesWebButton) {
        _subscription = widget.service.tokens.listen(
          (token) => unawaited(_exchange(() async => token)),
          onError: (Object error) {
            if (mounted) {
              setState(() => _error = GoogleAuthService.errorMessage(error));
            }
          },
        );
      }
      setState(() => _ready = true);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error =
              'Google sign-in could not load. Check your connection and retry, or sign in with email.',
        );
      }
    }
  }

  Future<void> _exchange(Future<String> Function() token) async {
    if (_busy || widget.disabled || !mounted) return;
    setState(() {
      _busy = true;
      _error = '';
    });
    widget.onBusyChanged(true);
    try {
      final credential = await token();
      if (!mounted) return;
      await widget.onToken(credential);
    } catch (error) {
      if (mounted) {
        setState(() => _error = GoogleAuthService.errorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        widget.onBusyChanged(false);
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.service.configured) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton(onPressed: null, child: Text('Continue with Google')),
          SizedBox(height: 8),
          Text(
            'Google sign-in is not enabled in this version. Use email to sign in or create an account.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error.isNotEmpty) ...[Notice(_error), const SizedBox(height: 12)],
        if (!_ready && _error.isNotEmpty)
          OutlinedButton(
            onPressed: _initialize,
            child: const Text('Retry Google sign-in'),
          )
        else if (!_ready || _busy)
          Center(
            child: ActionLabel(
              busy: true,
              label: 'Continue with Google',
              busyLabel: _busy ? 'Signing in…' : 'Loading Google sign-in…',
            ),
          )
        else if (widget.service.usesWebButton)
          // Remove the HTML button while email login is in flight, so an iframe
          // cannot start a competing authentication flow or retain keyboard focus.
          widget.disabled
              ? const OutlinedButton(
                  onPressed: null,
                  child: Text('Continue with Google'),
                )
              : Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) =>
                        googleWebButton(constraints.maxWidth),
                  ),
                )
        else
          OutlinedButton(
            onPressed: widget.disabled
                ? null
                : () => _exchange(widget.service.authenticate),
            child: const Text('Continue with Google'),
          ),
      ],
    );
  }
}
