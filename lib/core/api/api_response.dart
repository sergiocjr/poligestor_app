class ApiEnvelope<T> {
  ApiEnvelope({required this.data, this.meta});

  final T data;
  final Map<String, dynamic>? meta;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic raw) parseData,
  ) {
    return ApiEnvelope(
      data: parseData(json['data']),
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : null,
    );
  }
}
