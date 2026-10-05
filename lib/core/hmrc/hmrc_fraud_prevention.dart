import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../storage/secure_storage_service.dart';
import 'hmrc_local_ips.dart';

abstract interface class HmrcFraudPreventionHeaders {
  Future<Map<String, String>> headers();
}

class HmrcDeviceContext {
  final List<String> localIps;
  final DateTime collectedAt;
  final int screenWidth;
  final int screenHeight;
  final double scalingFactor;
  final int colourDepth;
  final String timezone;
  final String osFamily;
  final String osVersion;
  final String manufacturer;
  final String model;
  final String clientVersion;

  const HmrcDeviceContext({
    required this.localIps,
    required this.collectedAt,
    required this.screenWidth,
    required this.screenHeight,
    required this.scalingFactor,
    required this.colourDepth,
    required this.timezone,
    required this.osFamily,
    required this.osVersion,
    required this.manufacturer,
    required this.model,
    required this.clientVersion,
  });
}

abstract interface class HmrcDeviceContextProvider {
  Future<HmrcDeviceContext> collect();
}

class PlatformHmrcDeviceContextProvider implements HmrcDeviceContextProvider {
  final DeviceInfoPlugin deviceInfo;

  PlatformHmrcDeviceContextProvider({DeviceInfoPlugin? deviceInfo})
      : deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  @override
  Future<HmrcDeviceContext> collect() async {
    if (kIsWeb ||
        !const {
          TargetPlatform.android,
          TargetPlatform.iOS,
        }.contains(defaultTargetPlatform)) {
      throw StateError(
        'HMRC mobile fraud-prevention data is available only on Android and iOS.',
      );
    }

    final localIps = await collectLocalIpAddresses();
    // HMRC requires this timestamp to describe the IP collection itself,
    // immediately before the request that triggers the backend API call.
    final collectedAt = DateTime.now().toUtc();
    final package = await PackageInfo.fromPlatform();
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty || localIps.isEmpty) {
      throw StateError('Required HMRC device data is unavailable.');
    }
    final view = views.first;

    final scale = view.devicePixelRatio;
    final width = (view.physicalSize.width / scale).round();
    final height = (view.physicalSize.height / scale).round();
    String osFamily;
    String osVersion;
    String manufacturer;
    String model;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final info = await deviceInfo.androidInfo;
      osFamily = 'Android';
      osVersion = info.version.release;
      manufacturer = info.manufacturer;
      model = info.model;
    } else {
      final info = await deviceInfo.iosInfo;
      osFamily = info.systemName;
      osVersion = info.systemVersion;
      manufacturer = 'Apple';
      model = info.utsname.machine;
    }

    return HmrcDeviceContext(
      localIps: localIps,
      collectedAt: collectedAt,
      screenWidth: width,
      screenHeight: height,
      scalingFactor: scale,
      // Android and iOS Flutter surfaces use a standard 32-bit pixel format.
      colourDepth: 32,
      timezone: _timezone(DateTime.now().timeZoneOffset),
      osFamily: osFamily,
      osVersion: osVersion,
      manufacturer: manufacturer,
      model: model,
      clientVersion: '${package.version}+${package.buildNumber}',
    );
  }

  static String _timezone(Duration offset) {
    final totalMinutes = offset.inMinutes;
    final sign = totalMinutes >= 0 ? '+' : '-';
    final absolute = totalMinutes.abs();
    final hours = (absolute ~/ 60).toString().padLeft(2, '0');
    final minutes = (absolute % 60).toString().padLeft(2, '0');
    return 'UTC$sign$hours:$minutes';
  }
}

class HmrcFraudPreventionService implements HmrcFraudPreventionHeaders {
  final SecureStorageService storage;
  final HmrcDeviceContextProvider contextProvider;
  final Uuid uuid;

  HmrcFraudPreventionService(
    this.storage, {
    HmrcDeviceContextProvider? contextProvider,
    Uuid? uuid,
  })  : contextProvider =
            contextProvider ?? PlatformHmrcDeviceContextProvider(),
        uuid = uuid ?? const Uuid();

  @override
  Future<Map<String, String>> headers() async {
    final deviceId = await _deviceId();
    final context = await contextProvider.collect();
    return headersFor(deviceId, context);
  }

  Map<String, String> headersFor(
    String deviceId,
    HmrcDeviceContext context,
  ) {
    if (context.localIps.isEmpty ||
        context.screenWidth <= 0 ||
        context.screenHeight <= 0 ||
        context.scalingFactor <= 0 ||
        context.colourDepth <= 0 ||
        context.osFamily.trim().isEmpty ||
        context.osVersion.trim().isEmpty ||
        context.manufacturer.trim().isEmpty ||
        context.model.trim().isEmpty ||
        context.clientVersion.trim().isEmpty) {
      throw StateError('Required HMRC fraud-prevention data is unavailable.');
    }

    final scale = context.scalingFactor.toStringAsFixed(
      context.scalingFactor % 1 == 0 ? 0 : 2,
    );
    final localIps =
        context.localIps.toSet().map(Uri.encodeComponent).join(',');
    final userAgent = {
      'os-family': context.osFamily,
      'os-version': context.osVersion,
      'device-manufacturer': context.manufacturer,
      'device-model': context.model,
    }.entries.map((entry) {
      return '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}';
    }).join('&');

    return {
      'X-Cherry-HMRC-CONNECTION-METHOD': 'MOBILE_APP_VIA_SERVER',
      'X-Cherry-HMRC-DEVICE-ID': deviceId,
      'X-Cherry-HMRC-LOCAL-IPS': localIps,
      'X-Cherry-HMRC-LOCAL-IPS-TIMESTAMP': _timestamp(context.collectedAt),
      'X-Cherry-HMRC-SCREENS':
          'width=${context.screenWidth}&height=${context.screenHeight}'
              '&scaling-factor=$scale&colour-depth=${context.colourDepth}',
      'X-Cherry-HMRC-TIMEZONE': context.timezone,
      'X-Cherry-HMRC-USER-AGENT': userAgent,
      'X-Cherry-HMRC-WINDOW-SIZE':
          'width=${context.screenWidth}&height=${context.screenHeight}',
      'X-Cherry-HMRC-CLIENT-VERSION': context.clientVersion,
    };
  }

  Future<String> _deviceId() async {
    final stored = await storage.readHmrcDeviceId();
    if (stored != null && Uuid.isValidUUID(fromString: stored)) return stored;

    final generated = uuid.v4();
    await storage.saveHmrcDeviceId(generated);
    return generated;
  }

  String _timestamp(DateTime value) {
    final utc = value.toUtc();
    String two(int part) => part.toString().padLeft(2, '0');
    return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-'
        '${two(utc.day)}T${two(utc.hour)}:${two(utc.minute)}:'
        '${two(utc.second)}.${utc.millisecond.toString().padLeft(3, '0')}Z';
  }
}
