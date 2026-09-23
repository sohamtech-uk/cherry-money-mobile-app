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
              'Purchases are unavailable here. Demo mode and the Launch allowance still work. Try again in the configured iOS or Android app.';
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
          () => message = plan == Plan.launch
              ? 'No active paid Cherry Money entitlement was found. Refresh after any pending store approval.'
              : '${planDisplayName(plan).toUpperCase()} is active.',
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
            'Current plan: ${planDisplayName(state.plan).toUpperCase()} · ${state.remaining} demo actions left this month',
          ),
          const Notice(
            'Demo capture and approval each use one action. This prototype allowance is enforced on this device; live account actions continue to use Cherry Money permissions and confirmations.',
          ),
          if (packages.isNotEmpty)
            Text(
              'Available in your app store',
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
                    const SizedBox(height: 4),
                    Text(package.storeProduct.description),
                    const SizedBox(height: 8),
                    Text(
                      '${package.storeProduct.priceString} · ${package.packageType.name}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
          if (busy) const Center(child: CircularProgressIndicator()),
          if (message.isNotEmpty) Notice(message),
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
          const SizedBox(height: 20),
          Text(
            'Compare Cherry plans',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          _plan(
            'Launch',
            '£0',
            '3 actions per calendar month',
            'A free starting point for invoices, document review and starter reconciliation.',
          ),
          _plan(
            'Sole Trader',
            '£7 / month',
            '50 actions per calendar month',
            'Connected bookkeeping, invoicing and cash-flow tools for sole traders.',
          ),
          _plan(
            'Flow',
            '£15 / month',
            '100 actions per calendar month',
            'For businesses ready to keep invoicing, expenses, reconciliation and Ask Cherry moving together.',
          ),
          _plan(
            'Sole Trader Start',
            '£18 / month',
            '125 actions per calendar month',
            'More automation, VAT submission and MTD-ready workflows for a growing self-employed business.',
          ),
          _plan(
            'Thrive',
            '£35 / month',
            '250 actions per calendar month',
            'More headroom for VAT, reporting, cash-flow insights and higher document volume.',
          ),
          _plan(
            'Practice',
            '£99 / month',
            '500 actions per calendar month',
            'The highest mobile allowance for larger finance workflows and growing teams.',
          ),
          const SizedBox(height: 12),
          const Text(
            'Store prices and billing periods are shown by Apple or Google before purchase. Partner access will be introduced separately.',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _plan(
    String title,
    String price,
    String allowance,
    String description,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFAD1929),
                ),
              ),
            ],
          ),
          Text(allowance, style: const TextStyle(color: Color(0xFFAD1929))),
          const SizedBox(height: 8),
          Text(description),
        ],
      ),
    ),
  );
}
