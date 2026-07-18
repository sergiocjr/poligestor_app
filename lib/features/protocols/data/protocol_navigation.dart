/// Resolve o identificador interno do protocolo a partir de avisos/links.
class ProtocolNavigationTarget {
  const ProtocolNavigationTarget({
    required this.protocolId,
    this.protocolNumber,
    this.source = 'unknown',
  });

  final String protocolId;
  final String? protocolNumber;
  final String source;

  /// Prioridade: protocol_id → número PG- → segmento do link.
  static ProtocolNavigationTarget? resolve({
    String? protocolId,
    String? protocolNumber,
    String? link,
  }) {
    final id = protocolId?.trim();
    if (id != null && id.isNotEmpty && !_looksLikeProtocolNumber(id)) {
      return ProtocolNavigationTarget(
        protocolId: id,
        protocolNumber: protocolNumber,
        source: 'protocol_id',
      );
    }

    final fromLink = _idFromLink(link);
    if (fromLink != null && fromLink.isNotEmpty) {
      return ProtocolNavigationTarget(
        protocolId: fromLink,
        protocolNumber: protocolNumber,
        source: 'link',
      );
    }

    // Alguns backends aceitam o número no path; só como último recurso.
    final number = (protocolNumber?.trim().isNotEmpty ?? false)
        ? protocolNumber!.trim()
        : (id != null && _looksLikeProtocolNumber(id) ? id : null);
    if (number != null && number.isNotEmpty) {
      return ProtocolNavigationTarget(
        protocolId: number,
        protocolNumber: number,
        source: 'protocol_number',
      );
    }

    if (id != null && id.isNotEmpty) {
      return ProtocolNavigationTarget(
        protocolId: id,
        protocolNumber: protocolNumber,
        source: 'protocol_id_raw',
      );
    }

    return null;
  }

  static bool _looksLikeProtocolNumber(String value) {
    final v = value.trim().toUpperCase();
    return RegExp(r'^(PG|PORTAL)[-_]?\d', caseSensitive: false).hasMatch(v) ||
        v.startsWith('PG-') ||
        v.startsWith('PORTAL-');
  }

  static String? _idFromLink(String? link) {
    if (link == null || link.trim().isEmpty) return null;
    final uri = Uri.tryParse(link.trim());
    if (uri == null) return null;
    final segments = uri.pathSegments;
    for (var i = 0; i < segments.length - 1; i++) {
      final s = segments[i].toLowerCase();
      if (s == 'requests' ||
          s == 'protocols' ||
          s == 'solicitacoes' ||
          s == 'solicitação' ||
          s == 'protocolos') {
        final next = segments[i + 1].trim();
        if (next.isNotEmpty) return next;
      }
    }
    return uri.queryParameters['id'] ?? uri.queryParameters['protocol_id'];
  }

  String get citizenDetailPath => '/citizen/requests/$protocolId';
}
