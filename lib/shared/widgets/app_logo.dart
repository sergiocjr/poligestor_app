import 'package:flutter/material.dart';

import '../../../core/config.dart';

/// Logo oficial — usa branding do tenant quando houver URL pública.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 140,
    this.networkUrl,
    this.semanticLabel = 'PoliGestor',
  });

  final double height;
  final String? networkUrl;
  final String semanticLabel;

  static const asset = 'logo/poligestor_logo.png';

  @override
  Widget build(BuildContext context) {
    final url = networkUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel: semanticLabel,
        errorBuilder: (_, _, _) => Image.asset(
          asset,
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          semanticLabel: semanticLabel,
        ),
      );
    }
    return Image.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: semanticLabel.isEmpty ? AppConfig.appName : semanticLabel,
    );
  }
}
