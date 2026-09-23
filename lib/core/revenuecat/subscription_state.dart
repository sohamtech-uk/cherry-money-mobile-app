import '../config/app_config.dart';

enum Plan { launch, soleTrader, flow, soleTraderStart, thrive, practice }

Plan planForEntitlements(Iterable<String> active) =>
    active.contains(AppConfig.practiceEntitlement) ||
        active.contains(AppConfig.legacyBusinessEntitlement)
    ? Plan.practice
    : active.contains(AppConfig.thriveEntitlement)
    ? Plan.thrive
    : active.contains(AppConfig.soleTraderStartEntitlement)
    ? Plan.soleTraderStart
    : active.contains(AppConfig.flowEntitlement) ||
          active.contains(AppConfig.legacyCherryProEntitlement) ||
          active.contains(AppConfig.legacyProEntitlement)
    ? Plan.flow
    : active.contains(AppConfig.soleTraderEntitlement)
    ? Plan.soleTrader
    : Plan.launch;
int allowanceFor(Plan plan) => switch (plan) {
  Plan.launch => 3,
  Plan.soleTrader => 50,
  Plan.flow => 100,
  Plan.soleTraderStart => 125,
  Plan.thrive => 250,
  Plan.practice => 500,
};

String planDisplayName(Plan plan) => switch (plan) {
  Plan.launch => 'Launch',
  Plan.soleTrader => 'Sole Trader',
  Plan.flow => 'Flow',
  Plan.soleTraderStart => 'Sole Trader Start',
  Plan.thrive => 'Thrive',
  Plan.practice => 'Practice',
};
bool canProcess(Plan plan, int used) => used < allowanceFor(plan);
