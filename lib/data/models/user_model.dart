import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String username;
  final String fullname;
  final String email;
  final String? kontak;
  final String? nip;
  final String? clientId;
  final String? clientName;
  final String? departmentId;
  final String? departmentName;
  final String? positionId;
  final String? positionName;
  final String? noBpjs;
  final String? noJmo;
  final String status;
  final String role;
  final String? avatarUrl;
  final String? deviceId;
  final String? deviceName;
  final String? devicePlatform;
  final DateTime? lastLogin;
  final bool isOnline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.fullname,
    required this.email,
    this.kontak,
    this.nip,
    this.clientId,
    this.clientName,
    this.departmentId,
    this.departmentName,
    this.positionId,
    this.positionName,
    this.noBpjs,
    this.noJmo,
    required this.status,
    required this.role,
    this.avatarUrl,
    this.deviceId,
    this.deviceName,
    this.devicePlatform,
    this.lastLogin,
    this.isOnline = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      fullname: json['fullname'] ?? '',
      email: json['email'] ?? '',
      kontak: json['kontak'],
      nip: json['nip'],
      clientId: json['client_id'],
      clientName: json['client_name'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      positionId: json['position_id'],
      positionName: json['position_name'],
      noBpjs: json['no_bpjs'],
      noJmo: json['no_jmo'],
      status: json['status'] ?? 'active',
      role: json['role'] ?? 'employee',
      avatarUrl: json['avatar_url'],
      deviceId: json['device_id'],
      deviceName: json['device_name'],
      devicePlatform: json['device_platform'],
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      isOnline: json['is_online'] ?? false,
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
      'username': username,
      'fullname': fullname,
      'email': email,
      'kontak': kontak,
      'nip': nip,
      'client_id': clientId,
      'client_name': clientName,
      'department_id': departmentId,
      'department_name': departmentName,
      'position_id': positionId,
      'position_name': positionName,
      'no_bpjs': noBpjs,
      'no_jmo': noJmo,
      'status': status,
      'role': role,
      'avatar_url': avatarUrl,
      'device_id': deviceId,
      'device_name': deviceName,
      'device_platform': devicePlatform,
      'last_login': lastLogin?.toIso8601String(),
      'is_online': isOnline,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  UserModel copyWith({
    String? id,
    String? username,
    String? fullname,
    String? email,
    String? kontak,
    String? nip,
    String? clientId,
    String? clientName,
    String? departmentId,
    String? departmentName,
    String? positionId,
    String? positionName,
    String? noBpjs,
    String? noJmo,
    String? status,
    String? role,
    String? avatarUrl,
    String? deviceId,
    String? deviceName,
    String? devicePlatform,
    DateTime? lastLogin,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      kontak: kontak ?? this.kontak,
      nip: nip ?? this.nip,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      positionId: positionId ?? this.positionId,
      positionName: positionName ?? this.positionName,
      noBpjs: noBpjs ?? this.noBpjs,
      noJmo: noJmo ?? this.noJmo,
      status: status ?? this.status,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      devicePlatform: devicePlatform ?? this.devicePlatform,
      lastLogin: lastLogin ?? this.lastLogin,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, username, fullname, email,
    kontak, nip, clientId, clientName,
    departmentId, departmentName,
    positionId, positionName,
    noBpjs, noJmo, status, role,
    avatarUrl, deviceId, deviceName,
    devicePlatform, lastLogin, isOnline,
    createdAt, updatedAt,
  ];
}