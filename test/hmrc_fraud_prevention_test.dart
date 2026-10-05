import 'package:cherry_money_mobile/core/hmrc/hmrc_fraud_prevention.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_client_test.dart' show MemoryStorage;

class FixtureDeviceContext implements HmrcDeviceContextProvider {
  final HmrcDeviceContext value;
  const FixtureDeviceContext(this.value);

  @override
  Future<HmrcDeviceContext> collect() async => value;
}

void main() {
  final context = HmrcDeviceContext(
    localIps: ['fc00::1', '10.1.2.3'],
    collectedAt: DateTime.utc(2026, 10, 5, 0, 30, 5, 123),
    screenWidth: 390,
    screenHeight: 844,
    scalingFactor: 3,
    colourDepth: 32,
    timezone: 'UTC+01:00',
    osFamily: 'iOS',
    osVersion: '18.0',
    manufacturer: 'Apple',
    model: 'iPhone16,2',
    clientVersion: '5.1.0+503',
  );

  test(
    'builds the mobile-via-server telemetry required by the backend',
    () async {
      final storage = MemoryStorage()
        ..hmrcDeviceId = '3d8a8d57-1af9-4ccb-b87c-5bb7d05d9be7';
      final service = HmrcFraudPreventionService(
        storage,
        contextProvider: FixtureDeviceContext(context),
      );

      final headers = await service.headers();

      expect(headers, {
        'X-Cherry-HMRC-CONNECTION-METHOD': 'MOBILE_APP_VIA_SERVER',
        'X-Cherry-HMRC-DEVICE-ID': '3d8a8d57-1af9-4ccb-b87c-5bb7d05d9be7',
        'X-Cherry-HMRC-LOCAL-IPS': 'fc00%3A%3A1,10.1.2.3',
        'X-Cherry-HMRC-LOCAL-IPS-TIMESTAMP': '2026-10-05T00:30:05.123Z',
        'X-Cherry-HMRC-SCREENS':
            'width=390&height=844&scaling-factor=3&colour-depth=32',
        'X-Cherry-HMRC-TIMEZONE': 'UTC+01:00',
        'X-Cherry-HMRC-USER-AGENT':
            'os-family=iOS&os-version=18.0&device-manufacturer=Apple&device-model=iPhone16%2C2',
        'X-Cherry-HMRC-WINDOW-SIZE': 'width=390&height=844',
        'X-Cherry-HMRC-CLIENT-VERSION': '5.1.0+503',
      });
    },
  );

  test('fails closed when a required device value cannot be collected', () {
    final service = HmrcFraudPreventionService(
      MemoryStorage(),
      contextProvider: FixtureDeviceContext(
        HmrcDeviceContext(
          localIps: [],
          collectedAt: DateTime.utc(2026, 10, 5),
          screenWidth: 390,
          screenHeight: 844,
          scalingFactor: 3,
          colourDepth: 32,
          timezone: 'UTC+01:00',
          osFamily: 'iOS',
          osVersion: '18.0',
          manufacturer: 'Apple',
          model: 'iPhone16,2',
          clientVersion: '5.1.0+503',
        ),
      ),
    );

    expect(
      () => service.headersFor('3d8a8d57-1af9-4ccb-b87c-5bb7d05d9be7', context),
      returnsNormally,
    );
    expect(
      () => service.headersFor(
        '3d8a8d57-1af9-4ccb-b87c-5bb7d05d9be7',
        HmrcDeviceContext(
          localIps: [],
          collectedAt: DateTime.utc(2026, 10, 5),
          screenWidth: 390,
          screenHeight: 844,
          scalingFactor: 3,
          colourDepth: 32,
          timezone: 'UTC+01:00',
          osFamily: 'iOS',
          osVersion: '18.0',
          manufacturer: 'Apple',
          model: 'iPhone16,2',
          clientVersion: '5.1.0+503',
        ),
      ),
      throwsStateError,
    );
  });
}
