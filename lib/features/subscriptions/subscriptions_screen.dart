import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/revenuecat/subscription_state.dart';
import '../../core/widgets/common.dart';
import '../../data/repositories/workspace.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});
  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  bool busy = false;
  String message = '';
  List<Package> packages = [];
  @override
  void initState() {
    super.initState();
    Future.microtask(refresh);
  }

  Future<void> refresh() async {
    if (busy) {
      return;
    }
    setState(() {
      busy = true;
      message = '';
    });
    final state = ref.read(workspaceProvider);
    try {
      state.setPlan(await state.subscriptions.refresh());
      final offerings = await state.subscriptions.offerings();
      if (mounted) {
        setState(() {
          packages = offerings;
          message = offerings.isEmpty
              ? 'No plans are currently available to purchase.'
              : '';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          packages = [];
          message =
              'Purchases are unavailable here. Demo mode and the Free allowance still work. Try again in the configured iOS or Android app.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  Future<void> purchase(Package? package) async {
    if (busy) {
      return;
    }
    setState(() {
      busy = true;
      message = '';
    });
    final state = ref.read(workspaceProvider);
    try {
      final plan = package == null
          ? await state.subscriptions.restore()
          : await state.subscriptions.purchase(package);
      state.setPlan(plan);
      if (mounted) {
        setState(
          () => message = plan == Plan.free
              ? 'No active Cherry Money Pro entitlement was found. Refresh after any pending store approval.'
              : '${plan.name.toUpperCase()} is active.',
        );
      }
    } on PlatformException catch (error) {
      if (mounted) {
        setState(
          () => message =
              PurchasesErrorHelper.getErrorCode(error) ==
                  PurchasesErrorCode.purchaseCancelledError
              ? 'Purchase cancelled. Your plan has not changed.'
              : 'The store could not complete this request. Please try again.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => message =
              'Purchases could not be restored or completed. Please try again in the configured mobile app.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cherry plan')),
      body: PageBody(
        children: [
          Text(
            'More clarity.\nRoom to grow.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Current plan: ${state.plan.name.toUpperCase()} · ${state.remaining} demo actions left this month',
          ),
          const Notice(
            'Capture and approval each use one action. Allowances are enforced on this device in the demo; live finance automation is not connected.',
          ),
          _plan(
            'Free',
            '3 actions per calendar month',
            'Basic dashboard, document review and starter reconciliation.',
          ),
          _plan(
            'Pro',
            '100 actions per calendar month',
            'More capture and reconciliation actions, plus the detailed demo cashflow insight.',
          ),
          _plan(
            'Business',
            'Planned tier',
            'Team access and advanced agent workflows do not yet have a RevenueCat product and are not sold by this build.',
          ),
          if (busy) const Center(child: CircularProgressIndicator()),
          if (message.isNotEmpty) Notice(message),
          ...packages.map(
            (package) => Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      package.storeProduct.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(package.storeProduct.description),
                    Text(
                      '${package.storeProduct.priceString} · ${package.packageType.name}',
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: busy ? null : () => purchase(package),
                      child: const Text('Continue to store purchase'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          OutlinedButton(
            onPressed: busy ? null : () => purchase(null),
            child: const Text('Restore purchases'),
          ),
          TextButton(
            onPressed: busy ? null : refresh,
            child: const Text('Refresh plans and entitlement'),
          ),
          const Text(
            'Subscriptions use your Apple or Google store account and renew automatically unless cancelled in store settings. Confirm the billing period and price in the store sheet. Existing Cherry web subscriptions are separate.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Text(
            'Store release requires published privacy and subscription terms. No store publication has been performed.',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _plan(String title, String allowance, String description) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
          ),
          Text(allowance, style: const TextStyle(color: Color(0xFFAD1929))),
          const SizedBox(height: 8),
          Text(description),
        ],
      ),
    ),
  );
}
