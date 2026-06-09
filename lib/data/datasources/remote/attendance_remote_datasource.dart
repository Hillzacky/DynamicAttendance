import 'dart:io';
import 'package:dio/dio.dart';
import 'package:attendance_app/core/constants/api_constants.dart';
import 'package:attendance_app/core/network/dio_client.dart';
import 'package:attendance_app/data/models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceModel> createAttendance({
    required String locationId,
    required String shiftId,
    required String type,
    required double employeeLatitude,
    required double employeeLongitude,
    File? photo,
    String? notes,
    String? deviceId,
    String? deviceName,
  });

  Future<AttendanceModel> createManualAttendance({
    required String locationId,
    required String shiftId,
    required String type,
    required String manualDate,
    required String manualTime,
    required String manualReason,
    File? photo,
    String? notes,
    String? deviceId,
    String? deviceName,
  });

  Future<TodayAttendanceModel> getTodayAttendance();

  Future<Map<String, dynamic>> getAttendanceCalendar({
    required int month,
    required int year,
    String? userId,
    String? attendanceMode,
  });

  Future<Map<String, dynamic>> getAttendanceStatistics({
    required int month,
    required int year,
    String? userId,
  });

  Future<List<AttendanceModel>> getAttendances({
    int page = 1,
    int limit = 10,
    String? userId,
    String? type,
    String? status,
    String? attendanceMode,
    String? startDate,
    String? endDate,
  });

  Future<AttendanceModel> getAttendanceById(String id);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio _dio;

  AttendanceRemoteDataSourceImpl({Dio? dio})
      : _dio = dio ?? DioClient.instance;

  @override
  Future<AttendanceModel> createAttendance({
    required String locationId,
    required String shiftId,
    required String type,
    required double employeeLatitude,
    required double employeeLongitude,
    File? photo,
    String? notes,
    String? deviceId,
    String? deviceName,
  }) async {
    final formData = FormData.fromMap({
      'location_id': locationId,
      'shift_id': shiftId,
      'type': type,
      'attendance_mode': 'current',
      'employee_latitude': employeeLatitude,
      'employee_longitude': employeeLongitude,
      if (notes != null) 'notes': notes,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceName != null) 'device_name': deviceName,
      if (photo != null)
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: 'attendance_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
    });

    final response = await _dio.post(
      ApiConstants.attendances,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    return AttendanceModel.fromJson(response.data['data']);
  }

  @override
  Future<AttendanceModel> createManualAttendance({
    required String locationId,
    required String shiftId,
    required String type,
    required String manualDate,
    required String manualTime,
    required String manualReason,
    File? photo,
    String? notes,
    String? deviceId,
    String? deviceName,
  }) async {
    final formData = FormData.fromMap({
      'location_id': locationId,
      'shift_id': shiftId,
      'type': type,
      'attendance_mode': 'manual',
      'manual_date': manualDate,
      'manual_time': manualTime,
      'manual_reason': manualReason,
      if (notes != null) 'notes': notes,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceName != null) 'device_name': deviceName,
      if (photo != null)
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: 'manual_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
    });

    final response = await _dio.post(
      ApiConstants.attendanceManual,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    return AttendanceModel.fromJson(response.data['data']);
  }

  @override
  Future<TodayAttendanceModel> getTodayAttendance() async {
    final response = await _dio.get(ApiConstants.attendanceToday);
    return TodayAttendanceModel.fromJson(response.data['data']);
  }

  @override
  Future<Map<String, dynamic>> getAttendanceCalendar({
    required int month,
    required int year,
    String? userId,
    String? attendanceMode,
  }) async {
    final response = await _dio.get(
      ApiConstants.attendanceCalendar,
      queryParameters: {
        'month': month,
        'year': year,
        if (userId != null) 'user_id': userId,
        if (attendanceMode != null) 'attendance_mode': attendanceMode,
      },
    );
    return response.data['data'];
  }

  @override
  Future<Map<String, dynamic>> getAttendanceStatistics({
    required int month,
    required int year,
    String? userId,
  }) async {
    final response = await _dio.get(
      ApiConstants.attendanceStatistics,
      queryParameters: {
        'month': month,
        'year': year,
        if (userId != null) 'user_id': userId,
      },
    );
    return response.data['data'];
  }
  @override
  Future<List<AttendanceModel>> getAttendances({
    int page = 1,
    int limit = 10,
    String? userId,
    String? type,
    String? status,
    String? attendanceMode,
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dio.get(
      ApiConstants.attendances,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (userId != null) 'user_id': userId,
        if (type != null) 'type': type,
        if (status != null) 'status': status,
        if (attendanceMode != null) 'attendance_mode': attendanceMode,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      },
    );

    final List<dynamic> data = response.data['data'];
    return data.map((e) => AttendanceModel.fromJson(e)).toList();
  }

  @override
  Future<AttendanceModel> getAttendanceById(String id) async {
    final response = await _dio.get('${ApiConstants.attendances}/$id');
    return AttendanceModel.fromJson(response.data['data']);
  }
}