import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/repositories/workspace.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/account_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../features/transactions/transaction_detail.dart';
import '../features/reconciliation/reconciliation_screen.dart';
import '../features/ai_copilot/copilot_screen.dart';
import '../features/live/ask_cherry_screen.dart';
import '../features/live/features_screen.dart';
import '../features/live/records_screen.dart';
import '../features/live/finance_form.dart';
import '../features/documents/capture_screen.dart';
import '../features/subscriptions/subscriptions_screen.dart';
import '../features/settings/settings_screen.dart';
import 'theme/app_theme.dart';
import '../core/widgets/cherry_logo.dart';

class CherryApp extends ConsumerStatefulWidget {
  const CherryApp({super.key});
  @override
  ConsumerState<CherryApp> createState() => _CherryAppState();
}

class _CherryAppState extends ConsumerState<CherryApp>
    with WidgetsBindingObserver {
  late final GoRouter router;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final state = ref.read(workspaceProvider);
    router = GoRouter(
      initialLocation: '/',
      refreshListenable: state,
      redirect: (context, route) {
        final public = [
          '/',
          '/login',
          '/signup',
          '/forgot',
        ].contains(route.matchedLocation);
        return !public && !state.hasAccess ? '/' : null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, _) => const OnboardingScreen()),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (_, _) => const AccountScreen()),
        GoRoute(
          path: '/forgot',
          builder: (_, _) => const AccountScreen(reset: true),
        ),
        ShellRoute(
          builder: (_, route, child) =>
              MainShell(location: route.uri.path, child: child),
          routes: [
            GoRoute(path: '/home', builder: (_, _) => const DashboardScreen()),
            GoRoute(
              path: '/transactions',
              builder: (_, _) => const TransactionsScreen(),
            ),
            GoRoute(
              path: '/reconcile',
              builder: (_, _) => const ReconciliationScreen(),
            ),
            GoRoute(
              path: '/ask-cherry',
              builder: (_, _) =>
                  state.demo ? const CopilotScreen() : const AskCherryScreen(),
            ),
            GoRoute(path: '/copilot', redirect: (_, _) => '/ask-cherry'),
            GoRoute(
              path: '/features',
              builder: (_, _) => const FeaturesScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/transaction/:id',
          builder: (_, route) => TransactionDetail(route.pathParameters['id']!),
        ),
        GoRoute(
          path: '/capture',
          builder: (_, _) =>
              state.demo ? const CaptureScreen() : const FinanceForm('scan'),
        ),
        GoRoute(
          path: '/records/:kind',
          builder: (_, route) => RecordsScreen(
            route.pathParameters['kind']!,
            key: ValueKey(route.uri.path),
          ),
        ),
        GoRoute(
          path: '/create/:kind',
          builder: (_, route) => FinanceForm(
            route.pathParameters['kind']!,
            key: ValueKey(route.uri.path),
          ),
        ),
        GoRoute(
          path: '/subscriptions',
          builder: (_, _) => const SubscriptionsScreen(),
        ),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      ],
    );
    Future.microtask(state.refreshPlan);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(workspaceProvider).refreshPlan();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Cherry Money',
    debugShowCheckedModeBanner: false,
    theme: appTheme(),
    routerConfig: router,
  );
}

class MainShell extends ConsumerWidget {
  final String location;
  final Widget child;
  const MainShell({super.key, required this.location, required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workspaceProvider);
    const paths = [
      '/home',
      '/transactions',
      '/reconcile',
      '/ask-cherry',
      '/features',
    ];
    return Scaffold(
      appBar: AppBar(
        title: const CherryLogo(height: 44),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFF0E5E8),
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
            child: Text(
              state.demo
                  ? 'Demo data · Synthetic finance workspace'
                  : 'Live account · ${const AppConfigLabel().label}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF792031)),
            ),
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: paths.indexOf(location).clamp(0, 4),
        onDestinationSelected: (i) => context.go(paths[i]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            label: 'Reconcile',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            label: 'Ask Cherry',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class AppConfigLabel {
  const AppConfigLabel();
  String get label =>
      const String.fromEnvironment('CHERRY_ENV', defaultValue: 'development');
}
