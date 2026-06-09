import 'dart:io';
import 'package:dio/dio.dart';
import 'package:attendance_app/core/constants/api_constants.dart';
import 'package:attendance_app/core/network/dio_client.dart';
import 'package:attendance_app/data/models/leave_model.dart';

abstract class LeaveRemoteDataSource {
  Future<LeaveModel> createLeave({
    required String leaveTypeId,
    required String startDate,
    required String endDate,
    String? notes,
    File? document,
  });

  Future<List<LeaveModel>> getLeaves({
    int page = 1,
    int limit = 10,
    String? userId,
    String? status,
    String? leaveTypeId,
    String? startDate,
    String? endDate,
  });

  Future<LeaveModel> getLeaveById(String id);
  Future<LeaveModel> updateLeaveStatus({
    required String id,
    required String status,
    String? rejectionReason,
  });
  Future<void> cancelLeave(String id);
  Future<Map<String, dynamic>> getLeaveCalendar({
    required int month,
    required int year,
    String? userId,
  });
  Future<List<LeaveTypeModel>> getLeaveTypes();
  Future<void> deleteLeave(String id);
}

class LeaveRemoteDataSourceImpl implements LeaveRemoteDataSource {
  final Dio _dio;

  LeaveRemoteDataSourceImpl({Dio? dio})
      : _dio = dio ?? DioClient.instance;

  @override
  Future<LeaveModel> createLeave({
    required String leaveTypeId,
    required String startDate,
    required String endDate,
    String? notes,
    File? document,
  }) async {
    final formData = FormData.fromMap({
      'leave_type_id': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate,
      if (notes != null) 'notes': notes,
      if (document != null)
        'document': await MultipartFile.fromFile(
          document.path,
          filename: 'leave_${DateTime.now().millisecondsSinceEpoch}'
              '${document.path.endsWith('.pdf') ? '.pdf' : '.jpg'}',
        ),
    });
    final response = await _dio.post(
      ApiConstants.leaves,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    return LeaveModel.fromJson(response.data['data']);
  }

  @override
  Future<List<LeaveModel>> getLeaves({
    int page = 1,
    int limit = 10,
    String? userId,
    String? status,
    String? leaveTypeId,
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dio.get(
      ApiConstants.leaves,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (userId != null) 'user_id': userId,
        if (status != null) 'status': status,
        if (leaveTypeId != null) 'leave_type_id': leaveTypeId,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      },
    );

    final List<dynamic> data = response.data['data'];
    return data.map((e) => LeaveModel.fromJson(e)).toList();
  }

  @override
  Future<LeaveModel> getLeaveById(String id) async {
    final response = await _dio.get('${ApiConstants.leaves}/$id');
    return LeaveModel.fromJson(response.data['data']);
  }

  @override
  Future<LeaveModel> updateLeaveStatus({
    required String id,
    required String status,
    String? rejectionReason,
  }) async {
    final response = await _dio.put(
      '${ApiConstants.leaves}/$id/status',
      data: {
        'status': status,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      },
    );
    return LeaveModel.fromJson(response.data['data']);
  }

  @override
  Future<void> cancelLeave(String id) async {
    await _dio.put('${ApiConstants.leaves}/$id/cancel');
  }

  @override
  Future<Map<String, dynamic>> getLeaveCalendar({
    required int month,
    required int year,
    String? userId,
  }) async {
    final response = await _dio.get(
      ApiConstants.leaveCalendar,
      queryParameters: {
        'month': month,
        'year': year,
        if (userId != null) 'user_id': userId,
      },
    );
    return response.data['data'];
  }

  @override
  Future<List<LeaveTypeModel>> getLeaveTypes() async {
    final response = await _dio.get(ApiConstants.leaveTypes);
    final List<dynamic> data = response.data['data'];
    return data.map((e) => LeaveTypeModel.fromJson(e)).toList();
  }

  @override
  Future<void> deleteLeave(String id) async {
    await _dio.delete('${ApiConstants.leaves}/$id');
  }
}