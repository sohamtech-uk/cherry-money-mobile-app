import '../config/app_config.dart';

enum Plan { launch, flow, thrive, practice }

Plan planForEntitlements(Iterable<String> active) =>
    active.contains(AppConfig.practiceEntitlement) ||
        active.contains(AppConfig.legacyBusinessEntitlement)
    ? Plan.practice
    : active.contains(AppConfig.thriveEntitlement)
    ? Plan.thrive
    : active.contains(AppConfig.flowEntitlement) ||
          active.contains(AppConfig.legacyCherryProEntitlement) ||
          active.contains(AppConfig.legacyProEntitlement)
    ? Plan.flow
    : Plan.launch;
int allowanceFor(Plan plan) => switch (plan) {
  Plan.launch => 3,
  Plan.flow => 100,
  Plan.thrive => 250,
  Plan.practice => 500,
};
bool canProcess(Plan plan, int used) => used < allowanceFor(plan);
