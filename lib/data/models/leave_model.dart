import 'package:equatable/equatable.dart';

class LeaveModel extends Equatable {
  final String id;
  final String userId;
  final String? employeeName;
  final String? nip;
  final String clientId;
  final String? clientName;
  final String? departmentName;
  final String leaveTypeId;
  final String leaveTypeName;
  final String leaveTypeCode;
  final bool isPaid;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String status;
  final String? documentUrl;
  final String? documentType;
  final String? notes;
  final String? rejectionReason;
  final String? approvedBy;
  final String? approvedByName;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LeaveModel({
    required this.id,
    required this.userId,
    this.employeeName,
    this.nip,
    required this.clientId,
    this.clientName,
    this.departmentName,
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.leaveTypeCode,
    required this.isPaid,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.status,
    this.documentUrl,
    this.documentType,
    this.notes,
    this.rejectionReason,
    this.approvedBy,
    this.approvedByName,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      employeeName: json['employee_name'],
      nip: json['nip'],
      clientId: json['client_id'] ?? '',
      clientName: json['client_name'],
      departmentName: json['department_name'],
      leaveTypeId: json['leave_type_id'] ?? '',
      leaveTypeName: json['leave_type_name'] ?? '',
      leaveTypeCode: json['leave_type_code'] ?? '',
      isPaid: json['is_paid'] ?? true,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalDays: json['total_days'] ?? 1,
      status: json['status'] ?? 'pending',
      documentUrl: json['document_url'],
      documentType: json['document_type'],
      notes: json['notes'],
      rejectionReason: json['rejection_reason'],
      approvedBy: json['approved_by'],
      approvedByName: json['approved_by_name'],
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'employee_name': employeeName,
      'nip': nip,
      'client_id': clientId,
      'client_name': clientName,
      'department_name': departmentName,
      'leave_type_id': leaveTypeId,
      'leave_type_name': leaveTypeName,
      'leave_type_code': leaveTypeCode,
      'is_paid': isPaid,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_days': totalDays,
      'status': status,
      'document_url': documentUrl,
      'document_type': documentType,
      'notes': notes,
      'rejection_reason': rejectionReason,
      'approved_by': approvedBy,
      'approved_by_name': approvedByName,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  LeaveModel copyWith({
    String? id,
    String? userId,
    String? employeeName,
    String? nip,
    String? clientId,
    String? clientName,
    String? departmentName,
    String? leaveTypeId,
    String? leaveTypeName,
    String? leaveTypeCode,
    bool? isPaid,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    String? status,
    String? documentUrl,
    String? documentType,
    String? notes,
    String? rejectionReason,
    String? approvedBy,
    String? approvedByName,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      employeeName: employeeName ?? this.employeeName,
      nip: nip ?? this.nip,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      departmentName: departmentName ?? this.departmentName,
      leaveTypeId: leaveTypeId ?? this.leaveTypeId,
      leaveTypeName: leaveTypeName ?? this.leaveTypeName,
      leaveTypeCode: leaveTypeCode ?? this.leaveTypeCode,
      isPaid: isPaid ?? this.isPaid,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      status: status ?? this.status,
      documentUrl: documentUrl ?? this.documentUrl,
      documentType: documentType ?? this.documentType,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedByName: approvedByName ?? this.approvedByName,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, userId, employeeName, nip,
    clientId, clientName, departmentName,
    leaveTypeId, leaveTypeName, leaveTypeCode,
    isPaid, startDate, endDate, totalDays,
    status, documentUrl, documentType,
    notes, rejectionReason, approvedBy,
    approvedByName, approvedAt,
    createdAt, updatedAt,
  ];
}

// =============================================
// Leave Type Model
// =============================================
class LeaveTypeModel extends Equatable {
  final String id;
  final String name;
  final String code;
  final int maxDays;
  final bool isPaid;
  final bool requiresDocument;

  const LeaveTypeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.maxDays,
    required this.isPaid,
    required this.requiresDocument,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      maxDays: json['max_days'] ?? 0,
      isPaid: json['is_paid'] ?? true,
      requiresDocument: json['requires_document'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'max_days': maxDays,
      'is_paid': isPaid,
      'requires_document': requiresDocument,
    };
  }

  @override
  List<Object?> get props => [
    id, name, code, maxDays,
    isPaid, requiresDocument,
  ];
}

// =============================================
// Leave Calendar Model
// =============================================
class LeaveCalendarModel extends Equatable {
  final String leaveId;
  final String leaveTypeName;
  final String leaveTypeCode;
  final bool isPaid;
  final String status;
  final String? notes;
  final String? documentUrl;
  final String? documentType;
  final String startDate;
  final String endDate;
  final int totalDays;

  const LeaveCalendarModel({
    required this.leaveId,
    required this.leaveTypeName,
    required this.leaveTypeCode,
    required this.isPaid,
    required this.status,
    this.notes,
    this.documentUrl,
    this.documentType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
  });

  factory LeaveCalendarModel.fromJson(Map<String, dynamic> json) {
    return LeaveCalendarModel(
      leaveId: json['leave_id'] ?? '',
      leaveTypeName: json['leave_type_name'] ?? '',
      leaveTypeCode: json['leave_type_code'] ?? '',
      isPaid: json['is_paid'] ?? true,
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      documentUrl: json['document_url'],
      documentType: json['document_type'],
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalDays: json['total_days'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [
    leaveId, leaveTypeName, leaveTypeCode,
    isPaid, status, notes, documentUrl,
    documentType, startDate, endDate, totalDays,
  ];
}

// =============================================
// Leave Quota Model
// =============================================
class LeaveQuotaModel extends Equatable {
  final String leaveTypeId;
  final String leaveTypeName;
  final String leaveTypeCode;
  final int maxDays;
  final int usedDays;
  final int? remainingDays;
  final bool isPaid;
  final bool requiresDocument;
  const LeaveQuotaModel({
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.leaveTypeCode,
    required this.maxDays,
    required this.usedDays,
    this.remainingDays,
    required this.isPaid,
    required this.requiresDocument,
  });

  factory LeaveQuotaModel.fromJson(Map<String, dynamic> json) {
    return LeaveQuotaModel(
      leaveTypeId: json['leave_type_id'] ?? '',
      leaveTypeName: json['leave_type_name'] ?? '',
      leaveTypeCode: json['leave_type_code'] ?? '',
      maxDays: json['max_days'] ?? 0,
      usedDays: json['used_days'] ?? 0,
      remainingDays: json['remaining_days'],
      isPaid: json['is_paid'] ?? true,
      requiresDocument: json['requires_document'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
    leaveTypeId, leaveTypeName, leaveTypeCode,
    maxDays, usedDays, remainingDays,
    isPaid, requiresDocument,
  ];
}