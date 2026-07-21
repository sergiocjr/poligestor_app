import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../shared/demo/demo_repository_support.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import 'protocol_models.dart';

class CreateProtocolInput {
  CreateProtocolInput({
    required this.subject,
    required this.description,
    this.category,
    this.priority = 'medium',
    this.latitude,
    this.longitude,
    this.locationLabel,
    this.dataConsent = true,
  });

  final String subject;
  final String description;
  final String? category;
  final String priority;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;
  final bool dataConsent;

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'title': subject,
    'description': description,
    if (category != null) 'category': category,
    'priority': priority,
    'data_consent': dataConsent,
    if (latitude != null || longitude != null || locationLabel != null)
      'metadata': {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (locationLabel != null) 'location_label': locationLabel,
      },
  };
}

class ProtocolRatingInput {
  ProtocolRatingInput({
    required this.stars,
    required this.resolved,
    this.comment,
    this.nps,
  });

  final int stars;
  final bool resolved;
  final String? comment;

  /// Preparado: incluído no JSON só se preenchido (API pode ignorar).
  final int? nps;

  Map<String, dynamic> toJson() => {
    'stars': stars,
    'rating': stars,
    'score': stars,
    'resolved': resolved,
    'problema_resolvido': resolved,
    if (comment != null && comment!.trim().isNotEmpty)
      'comment': comment!.trim(),
    if (comment != null && comment!.trim().isNotEmpty)
      'comentario': comment!.trim(),
    if (nps != null) 'nps': nps,
  };
}

class ProtocolsRepository {
  ProtocolsRepository(this._api);

  final ApiClient _api;
  final Map<String, CancelToken> _uploads = {};

  Future<List<ProtocolSummary>> list({
    required AuthMode mode,
    Map<String, dynamic>? query,
  }) async {
    final envelope = await _api.getEnvelope<List<ProtocolSummary>>(
      mode.protocolsPath,
      query: query,
      mode: mode,
      parse: (raw) {
        final list = _asList(raw);
        return list
            .whereType<Map>()
            .map((e) => ProtocolSummary.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
    return envelope.data;
  }

  Future<ProtocolDetail> getById({
    required AuthMode mode,
    required dynamic id,
  }) async {
    final envelope = await _api.getEnvelope<ProtocolDetail>(
      '${mode.protocolsPath}/$id',
      mode: mode,
      parse: (raw) {
        if (raw is Map<String, dynamic>) return ProtocolDetail.fromJson(raw);
        if (raw is Map) {
          return ProtocolDetail.fromJson(Map<String, dynamic>.from(raw));
        }
        throw Exception('Protocolo inválido');
      },
    );
    return envelope.data;
  }

  Future<ProtocolDetail> create({
    required AuthMode mode,
    required CreateProtocolInput input,
  }) async {
    final envelope = await _api.postEnvelope<ProtocolDetail>(
      mode.protocolsPath,
      data: input.toJson(),
      mode: mode,
      parse: (raw) {
        if (raw is Map<String, dynamic>) return ProtocolDetail.fromJson(raw);
        if (raw is Map) {
          return ProtocolDetail.fromJson(Map<String, dynamic>.from(raw));
        }
        throw Exception('Resposta de criação inválida');
      },
    );
    return envelope.data;
  }

  /// Envia complemento/resposta pública (conversa cidadão ↔ gabinete).
  Future<ProtocolMessage> addComment({
    required AuthMode mode,
    required dynamic protocolId,
    required String body,
  }) async {
    final envelope = await _api.postEnvelope<ProtocolMessage>(
      '${mode.protocolsPath}/$protocolId/comments',
      data: {'body': body},
      mode: mode,
      parse: (raw) {
        if (raw is Map<String, dynamic>) return ProtocolMessage.fromJson(raw);
        if (raw is Map) {
          return ProtocolMessage.fromJson(Map<String, dynamic>.from(raw));
        }
        throw Exception('Comentário inválido');
      },
    );
    return envelope.data;
  }

  /// Marca mensagens como lidas: `POST …/protocols/{id}/read` (contrato).
  Future<bool> markMessagesRead({
    required AuthMode mode,
    required ProtocolDetail detail,
  }) async {
    final candidates = <String>[];
    final fromLink = detail.markReadUrl;
    if (fromLink != null && fromLink.trim().isNotEmpty) {
      final path = _toApiPath(fromLink);
      if (path != null) candidates.add(path);
    }
    candidates.add(mode.protocolReadPath(detail.id));

    for (final path in candidates.toSet()) {
      try {
        await _api.postEnvelope<Map<String, dynamic>>(
          path,
          data: const {},
          mode: mode,
          parse: (raw) {
            if (raw is Map<String, dynamic>) return raw;
            if (raw is Map) return Map<String, dynamic>.from(raw);
            return <String, dynamic>{};
          },
        );
        return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  /// Envia avaliação somente se a API indicar URL/`can_rate`.
  Future<bool> submitRating({
    required AuthMode mode,
    required ProtocolDetail detail,
    required ProtocolRatingInput input,
  }) async {
    final candidates = <String>[];
    final url = detail.rateUrl;
    if (url != null && url.trim().isNotEmpty) {
      final path = _toApiPath(url);
      if (path != null) candidates.add(path);
    }
    // LIVE: `can_rate=true` pode vir sem `links.rate` — usa rotas convencionais.
    if (detail.canRate) {
      candidates.add('${mode.protocolsPath}/${detail.id}/rating');
      candidates.add('${mode.protocolsPath}/${detail.id}/rate');
    }
    if (candidates.isEmpty) {
      throw const ProtocolFeatureUnavailable(
        'A avaliação ainda não está disponível para esta solicitação.',
      );
    }

    Object? lastError;
    for (final path in candidates.toSet()) {
      try {
        await _api.postEnvelope<Map<String, dynamic>>(
          path,
          data: input.toJson(),
          mode: mode,
          parse: (raw) {
            if (raw is Map<String, dynamic>) return raw;
            if (raw is Map) return Map<String, dynamic>.from(raw);
            return <String, dynamic>{};
          },
        );
        return true;
      } catch (e) {
        lastError = e;
        // 404/405 → tenta candidato seguinte; outros erros sobem.
        if (e is ApiException && (e.statusCode == 404 || e.statusCode == 405)) {
          continue;
        }
        final msg = e.toString().toLowerCase();
        if (msg.contains('404') ||
            msg.contains('405') ||
            msg.contains('not found') ||
            msg.contains('não encontr')) {
          continue;
        }
        rethrow;
      }
    }
    if (lastError != null) throw lastError;
    throw const ProtocolFeatureUnavailable(
      'A avaliação ainda não está disponível para esta solicitação.',
    );
  }

  Future<ProtocolAttachment> uploadAttachment({
    required AuthMode mode,
    required dynamic protocolId,
    required String filePath,
    required String fileName,
    String? mimeType,
    void Function(double progress)? onProgress,
    String? uploadId,
  }) async {
    final id = uploadId ?? filePath;
    final token = CancelToken();
    _uploads[id] = token;
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        if (mimeType != null) 'mime_type': mimeType,
      });
      final response = await _api.raw.post<Map<String, dynamic>>(
        '${mode.protocolsPath}/$protocolId/attachments',
        data: form,
        cancelToken: token,
        onSendProgress: (sent, total) {
          if (total > 0 && onProgress != null) {
            onProgress(sent / total);
          }
        },
        options: Options(
          contentType: 'multipart/form-data',
          extra: {'authMode': mode},
        ),
      );
      final raw = response.data?['data'] ?? response.data;
      if (raw is Map) {
        return ProtocolAttachment.fromJson(Map<String, dynamic>.from(raw));
      }
      return ProtocolAttachment(id: id, name: fileName, mimeType: mimeType);
    } finally {
      _uploads.remove(id);
    }
  }

  void cancelUpload(String uploadId) {
    final token = _uploads.remove(uploadId);
    token?.cancel('cancelado');
  }

  Future<ProtocolStats> stats({required AuthMode mode}) async {
    final items = await list(mode: mode);
    return ProtocolStats.fromList(items);
  }

  String? _toApiPath(String urlOrPath) {
    final trimmed = urlOrPath.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('/v1/')) return trimmed;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;
    final path = uri.path;
    final idx = path.indexOf('/v1/');
    if (idx >= 0) return path.substring(idx);
    if (path.startsWith('/api/v1/')) return path.substring(4);
    return null;
  }

  List<dynamic> _asList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      for (final key in ['data', 'items', 'protocols', 'protocolos']) {
        final c = raw[key];
        if (c is List) return c;
      }
    }
    return const [];
  }
}

class ProtocolFeatureUnavailable implements Exception {
  const ProtocolFeatureUnavailable(this.message);
  final String message;

  @override
  String toString() => message;
}

class ProtocolStats {
  ProtocolStats({
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.total,
  });

  final int open;
  final int inProgress;
  final int resolved;
  final int total;

  factory ProtocolStats.fromList(List<ProtocolSummary> items) {
    var open = 0, inProgress = 0, resolved = 0;
    for (final i in items) {
      if (i.isResolved) {
        resolved++;
      } else if (i.isInProgress || i.isAwaitingCitizen) {
        inProgress++;
      } else {
        open++;
      }
    }
    return ProtocolStats(
      open: open,
      inProgress: inProgress,
      resolved: resolved,
      total: items.length,
    );
  }
}
