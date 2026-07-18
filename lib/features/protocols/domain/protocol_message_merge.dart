import '../data/protocol_models.dart';

/// Mescla mensagens recebidas sem duplicar por id (tempo real / polling).
List<ProtocolMessage> mergeProtocolMessages(
  List<ProtocolMessage> current,
  List<ProtocolMessage> incoming,
) {
  final byId = <String, ProtocolMessage>{};
  for (final m in current) {
    byId['${m.id}'] = m;
  }
  for (final m in incoming) {
    byId['${m.id}'] = m;
  }
  final out = byId.values.toList()
    ..sort((a, b) {
      final aAt = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bAt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aAt.compareTo(bAt);
    });
  return out;
}

bool isNearScrollEnd(double offset, double maxExtent, {double threshold = 120}) {
  if (maxExtent <= 0) return true;
  return (maxExtent - offset) <= threshold;
}
