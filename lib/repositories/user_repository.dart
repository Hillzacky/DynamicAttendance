import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class User {
  final String id;
  final String username;
  final String password;
  final String fullname;
  final String email;
  final String? kontak;
  final String? nip;
  final String? client;
  final String? departement;
  final String? posisi;
  final String? no_bpjs;
  final String? no_jmo;
  final String status;
  final String? device;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    String? id,
    required this.username,
    required this.password,
    required this.fullname,
    required this.email,
    this.kontak,
    this.nip,
    this.client,
    this.departement,
    this.posisi,
    this.no_bpjs,
    this.no_jmo,
    this.status = 'active',
    this.device,
    DateTime? createdAt,
    DateTime? updatedAt,
  })
      : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullname': fullname,
      'email': email,
      'kontak': kontak,
      'nip': nip,
      'client': client,
      'departement': departement,
      'posisi': posisi,
      'no_bpjs': no_bpjs,
      'no_jmo': no_jmo,
      'status': status,
      'device': device,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      fullname: map['fullname'] as String,
      email: map['email'] as String,
      kontak: map['kontak'] as String?,
      nip: map['nip'] as String?,
      client: map['client'] as String?,
      departement: map['departement'] as String?,
      posisi: map['posisi'] as String?,
      no_bpjs: map['no_bpjs'] as String?,
      no_jmo: map['no_jmo'] as String?,
      status: map['status'] as String? ?? 'active',
      device: map['device'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? fullname,
    String? email,
    String? kontak,
    String? nip,
    String? client,
    String? departement,
    String? posisi,
    String? no_bpjs,
    String? no_jmo,
    String? status,
    String? device,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      kontak: kontak ?? this.kontak,
      nip: nip ?? this.nip,
      client: client ?? this.client,
      departement: departement ?? this.departement,
      posisi: posisi ?? this.posisi,
      no_bpjs: no_bpjs ?? this.no_bpjs,
      no_jmo: no_jmo ?? this.no_jmo,
      status: status ?? this.status,
      device: device ?? this.device,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, fullname: $fullname, email: $email)';
  }
}