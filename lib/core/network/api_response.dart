class ApiResponse<T> {
  final String status;
  final int statusCode;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;
  final Map<String, List<String>>? errors;

  const ApiResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
    this.meta,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      status: json['status'] ?? 'success',
      statusCode: json['statusCode'] ?? 200,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      meta: json['meta'] != null
          ? Map<String, dynamic>.from(json['meta'])
          : null,
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map(
                (key, value) => MapEntry(
                  key,
                  List<String>.from(value),
                ),
              ),
            )
          : null,
    );
  }

  bool get isSuccess => status == 'success';
  bool get hasData => data != null;
  bool get hasMeta => meta != null;
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  PaginationMeta? get pagination => meta != null
      ? PaginationMeta.fromJson(meta!)
      : null;
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}