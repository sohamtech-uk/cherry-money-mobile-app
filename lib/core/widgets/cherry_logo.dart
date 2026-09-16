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
      // Multiply maps the supplied artwork's white paper to the page surface.
      color: Theme.of(context).scaffoldBackgroundColor,
      colorBlendMode: BlendMode.multiply,
      semanticLabel: 'Cherry Money',
    ),
  );
}
