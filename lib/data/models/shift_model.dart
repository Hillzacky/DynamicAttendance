import 'package:equatable/equatable.dart';

class ShiftModel extends Equatable {
  final String id;
  final String? clientId;
  final String? clientName;
  final String name;
  final String? code;
  final String checkInTime;
  final String checkOutTime;
  final int lateTolerance;
  final int earlyLeaveTolerance;
  final bool isOvernight;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ShiftModel({
    required this.id,
    this.clientId,
    this.clientName,
    required this.name,
    this.code,
    required this.checkInTime,
    required this.checkOutTime,
    this.lateTolerance = 0,
    this.earlyLeaveTolerance = 0,
    this.isOvernight = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] ?? '',
      clientId: json['client_id'],
      clientName: json['client_name'],
      name: json['name'] ?? '',
      code: json['code'],
      checkInTime: json['check_in_time'] ?? '08:00',
      checkOutTime: json['check_out_time'] ?? '17:00',
      lateTolerance: json['late_tolerance'] ?? 0,
      earlyLeaveTolerance: json['early_leave_tolerance'] ?? 0,
      isOvernight: json['is_overnight'] ?? false,
      isActive: json['is_active'] ?? true,
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
      'client_id': clientId,
      'client_name': clientName,
      'name': name,
      'code': code,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'late_tolerance': lateTolerance,
      'early_leave_tolerance': earlyLeaveTolerance,
      'is_overnight': isOvernight,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ShiftModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? name,
    String? code,
    String? checkInTime,
    String? checkOutTime,
    int? lateTolerance,
    int? earlyLeaveTolerance,
    bool? isOvernight,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      name: name ?? this.name,
      code: code ?? this.code,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      lateTolerance: lateTolerance ?? this.lateTolerance,
      earlyLeaveTolerance: earlyLeaveTolerance ?? this.earlyLeaveTolerance,
      isOvernight: isOvernight ?? this.isOvernight,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, clientId, clientName, name, code,
    checkInTime, checkOutTime, lateTolerance,
    earlyLeaveTolerance, isOvernight, isActive,
    createdAt, updatedAt,
  ];
}