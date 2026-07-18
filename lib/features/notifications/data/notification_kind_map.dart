import 'push_payload.dart';

PushEventType pushEventTypeFrom(String raw) {
  final t = raw.trim().toLowerCase();
  return switch (t) {
    'protocol_message' ||
    'new_reply' ||
    'new_message' ||
    'message' ||
    'resposta' ||
    'mensagem' =>
      PushEventType.protocolMessage,
    'protocol_information_requested' ||
    'info_request' ||
    'awaiting_citizen' ||
    'pedido_informacao' ||
    'information_requested' =>
      PushEventType.protocolInformationRequested,
    'protocol_status_changed' ||
    'status_change' ||
    'status' ||
    'status_changed' =>
      PushEventType.protocolStatusChanged,
    'protocol_resolved' ||
    'resolved' ||
    'closed' ||
    'concluido' ||
    'concluído' =>
      PushEventType.protocolResolved,
    'protocol_rating_available' ||
    'rating_available' ||
    'rating' ||
    'avaliacao' ||
    'avaliação' =>
      PushEventType.protocolRatingAvailable,
    'system_notice' || 'system' || 'aviso' || 'notice' =>
      PushEventType.systemNotice,
    _ => PushEventType.unknown,
  };
}
