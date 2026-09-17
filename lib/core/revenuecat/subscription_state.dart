import '../config/app_config.dart';

enum Plan { free, pro, business }

Plan planForEntitlements(Iterable<String> active) =>
    active.contains(AppConfig.businessEntitlement)
    ? Plan.business
    : active.contains(AppConfig.proEntitlement) ||
          active.contains(AppConfig.legacyProEntitlement)
    ? Plan.pro
    : Plan.free;
int allowanceFor(Plan plan) => switch (plan) {
  Plan.free => 3,
  Plan.pro => 100,
  Plan.business => 500,
};
bool canProcess(Plan plan, int used) => used < allowanceFor(plan);
