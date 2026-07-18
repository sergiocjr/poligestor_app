import 'package:flutter/material.dart';

/// Logo oficial do PoliGestor.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 140,
  });

  final double height;

  static const asset = 'logo/poligestor_logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'PoliGestor',
    );
  }
}
