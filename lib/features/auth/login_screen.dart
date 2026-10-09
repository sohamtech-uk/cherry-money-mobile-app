import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/workspace.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/cherry_logo.dart';
import 'apple_sign_in_control.dart';
import 'google_sign_in_control.dart';
import 'mobile_mfa_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController(), password = TextEditingController();
  final form = GlobalKey<FormState>();
  bool googleBusy = false;
  bool appleBusy = false;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceProvider);
    if (state.mfaChallenge != null) {
      return MobileMfaScreen(
        busy: state.busy,
        error: state.error,
        onCancel: state.cancelMfa,
        onVerify: (code) async {
          await state.verifyMfa(code);
          if (context.mounted && state.signedIn) {
            context.go('/home');
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cherry Money')),
      body: PageBody(
        children: [
          const CherryLogo(),
          const SizedBox(height: 24),
          Text(
            'Welcome back.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            'Sign in to see your Cherry account overview. Or explore the complete synthetic finance workflow in demo mode.',
          ),
          const SizedBox(height: 24),
          Form(
            key: form,
            child: Column(
              children: [
                TextFormField(
                  controller: email,
                  decoration: const InputDecoration(
                    labelText: 'Business email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (v) => v != null && v.contains('@')
                      ? null
                      : 'Enter your email address',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: password,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  validator: (v) =>
                      v?.isNotEmpty == true ? null : 'Enter your password',
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: state.busy || googleBusy || appleBusy
                  ? null
                  : () => context.go('/forgot'),
              child: const Text('Forgot password? Reset here'),
            ),
          ),
          if (state.error.isNotEmpty) Notice(state.error),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: (state.busy || googleBusy || appleBusy)
                ? null
                : () async {
                    if (!form.currentState!.validate()) {
                      return;
                    }
                    await state.login(email.text.trim(), password.text);
                    password.clear();
                    if (context.mounted && state.signedIn) {
                      context.go('/home');
                    }
                  },
            child: ActionLabel(
              busy: state.busy,
              label: 'Sign in',
              busyLabel: 'Signing in…',
            ),
          ),
          const SizedBox(height: 16),
          const Center(child: Text('Or continue with')),
          const SizedBox(height: 16),
          GoogleSignInControl(
            disabled: state.busy || googleBusy || appleBusy,
            onBusyChanged: (busy) {
              if (mounted) setState(() => googleBusy = busy);
            },
            onToken: (token) async {
              await state.loginWithGoogle(token);
              if (context.mounted && state.signedIn) context.go('/home');
            },
          ),
          AppleSignInControl(
            disabled: state.busy || googleBusy || appleBusy,
            onBusyChanged: (busy) {
              if (mounted) setState(() => appleBusy = busy);
            },
            onToken: (token) async {
              await state.loginWithApple(token);
              if (context.mounted && state.signedIn) context.go('/home');
            },
          ),
          TextButton(
            onPressed: state.busy || googleBusy || appleBusy
                ? null
                : () => context.go('/signup'),
            child: const Text('Create new account'),
          ),
          TextButton(
            onPressed: (state.busy || googleBusy || appleBusy)
                ? null
                : () async {
                    await state.startDemo();
                    if (context.mounted) {
                      context.go('/home');
                    }
                  },
            child: const Text('Try demo'),
          ),
        ],
      ),
    );
  }
}
