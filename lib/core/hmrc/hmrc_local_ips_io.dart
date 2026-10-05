import 'dart:io';

Future<List<String>> collectLocalIpAddresses() async {
  final addresses = <String>{};
  final interfaces = await NetworkInterface.list(
    includeLinkLocal: true,
    type: InternetAddressType.any,
  );

  for (final interface in interfaces) {
    for (final address in interface.addresses) {
      if (address.isLoopback) continue;

      // Dart can append an interface zone (for example "%en0") to a
      // link-local IPv6 address. HMRC expects an IP literal, so omit the
      // local-only zone identifier while retaining the address.
      final literal = address.address.split('%').first;
      if (literal.isNotEmpty) addresses.add(literal);
    }
  }

  return addresses.toList()..sort();
}
