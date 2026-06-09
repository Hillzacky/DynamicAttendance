import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  final String id;
  final String? clientId;
  final String? clientName;
  final String name;
  final String? code;
  final String address;
  final double latitude;
  final double longitude;
  final int radius;
  final bool isPrimary;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LocationModel({
    required this.id,
    this.clientId,
    this.clientName,
    required this.name,
    this.code,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isPrimary = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      clientId: json['client_id'],
      clientName: json['client_name'],
      name: json['name'] ?? '',
      code: json['code'],
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      radius: json['radius'] ?? 100,
      isPrimary: json['is_primary'] ?? false,
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
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'is_primary': isPrimary,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  LocationModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? name,
    String? code,
    String? address,
    double? latitude,
    double? longitude,
    int? radius,
    bool? isPrimary,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, clientId, clientName, name, code,
    address, latitude, longitude, radius,
    isPrimary, isActive, createdAt, updatedAt,
  ];
}