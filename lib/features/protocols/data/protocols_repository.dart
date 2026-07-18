import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
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
  });

  final String subject;
  final String description;
  final String? category;
  final String priority;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'description': description,
        if (category != null) 'category': category,
        'priority': priority,
        if (latitude != null || longitude != null || locationLabel != null)
          'metadata': {
            if (latitude != null) 'latitude': latitude,
            if (longitude != null) 'longitude': longitude,
            if (locationLabel != null) 'location_label': locationLabel,
          },
      };
}

class ProtocolsRepository {
  ProtocolsRepository(this._api);

  final ApiClient _api;

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

  Future<ProtocolComment> addComment({
    required AuthMode mode,
    required dynamic protocolId,
    required String body,
  }) async {
    final envelope = await _api.postEnvelope<ProtocolComment>(
      '${mode.protocolsPath}/$protocolId/comments',
      data: {'body': body},
      mode: mode,
      parse: (raw) {
        if (raw is Map<String, dynamic>) return ProtocolComment.fromJson(raw);
        if (raw is Map) {
          return ProtocolComment.fromJson(Map<String, dynamic>.from(raw));
        }
        throw Exception('Comentário inválido');
      },
    );
    return envelope.data;
  }

  Future<void> uploadAttachment({
    required AuthMode mode,
    required dynamic protocolId,
    required String filePath,
    required String fileName,
    String? mimeType,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      if (mimeType != null) 'mime_type': mimeType,
    });
    await _api.raw.post(
      '${mode.protocolsPath}/$protocolId/attachments',
      data: form,
      options: Options(
        contentType: 'multipart/form-data',
        extra: {'authMode': mode},
      ),
    );
  }

  Future<ProtocolStats> stats({required AuthMode mode}) async {
    final items = await list(mode: mode);
    return ProtocolStats.fromList(items);
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
      } else if (i.isInProgress) {
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
