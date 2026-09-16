import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/widgets/common.dart';
import '../../data/repositories/workspace.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workspaceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: PageBody(
        children: [
          Text(
            state.demo ? 'Demo workspace' : 'Cherry account',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Notice(
            'Demo data is synthetic. Demo decisions reset when you start a new demo session. Usage counts remain on this device for the calendar month.',
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Plans and purchases'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/subscriptions'),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Privacy and data'),
            subtitle: const Text(
              'Auth tokens use OS secure storage. Selected documents stay on your device. Demo audit events are session history, not an immutable record.',
            ),
          ),
          ListTile(
            title: const Text('API environment'),
            subtitle: Text(const AppConfig().environment),
          ),
          if (!state.demo)
            OutlinedButton(
              onPressed: () async {
                await state.signOut();
                await state.startDemo();
                if (context.mounted) {
                  context.go('/home');
                }
              },
              child: const Text('Sign out and try demo'),
            ),
          OutlinedButton(
            onPressed: () async {
              await state.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(state.demo ? 'Leave demo' : 'Sign out'),
          ),
        ],
      ),
    );
  }
}
