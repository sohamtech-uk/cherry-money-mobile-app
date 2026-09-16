import 'package:flutter/material.dart';

class CherryLogo extends StatelessWidget {
  final double height;
  const CherryLogo({super.key, this.height = 112});
  @override
  Widget build(BuildContext context) => Center(
    child: Image.asset(
      'assets/images/cherrymoney-logo.png',
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'Cherry Money',
    ),
  );
}
