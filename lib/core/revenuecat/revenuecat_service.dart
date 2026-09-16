import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/app_config.dart';
import 'subscription_state.dart';

abstract class SubscriptionRepository {
  Future<void> initialize();
  Future<Plan> refresh();
  Future<List<Package>> offerings();
  Future<Plan> purchase(Package package);
  Future<Plan> restore();
}

class RevenueCatService implements SubscriptionRepository {
  final AppConfig config;
  bool ready = false;
  RevenueCatService(this.config);
  @override
  Future<void> initialize() async {
    if (ready) {
      return;
    }
    if (kIsWeb ||
        ![
          TargetPlatform.iOS,
          TargetPlatform.android,
        ].contains(defaultTargetPlatform)) {
      throw StateError('Purchases require the iOS or Android app.');
    }
    final key = defaultTargetPlatform == TargetPlatform.iOS
        ? config.iosKey
        : config.androidKey;
    if (key.isEmpty || key == 'replace_me') {
      throw StateError('RevenueCat is not configured.');
    }
    await Purchases.configure(PurchasesConfiguration(key));
    ready = true;
  }

  Plan _plan(CustomerInfo info) =>
      planForEntitlements(info.entitlements.active.keys);
  @override
  Future<Plan> refresh() async {
    await initialize();
    return _plan(await Purchases.getCustomerInfo());
  }

  @override
  Future<List<Package>> offerings() async {
    await initialize();
    return (await Purchases.getOfferings()).current?.availablePackages ?? [];
  }

  @override
  Future<Plan> purchase(Package package) async {
    await initialize();
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return _plan(result.customerInfo);
  }

  @override
  Future<Plan> restore() async {
    await initialize();
    return _plan(await Purchases.restorePurchases());
  }
}
