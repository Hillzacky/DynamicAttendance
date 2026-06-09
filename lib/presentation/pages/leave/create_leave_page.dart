import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_app/core/theme/app_theme.dart';
import 'package:attendance_app/presentation/bloc/leave/leave_bloc.dart';
import 'package:attendance_app/presentation/bloc/leave/leave_event.dart';
import 'package:attendance_app/presentation/bloc/leave/leave_state.dart';
import 'package:attendance_app/presentation/widgets/common/app_button.dart';
import 'package:attendance_app/presentation/widgets/common/app_text_field.dart';
import 'package:attendance_app/presentation/widgets/common/app_snackbar.dart';
import 'package:attendance_app/presentation/widgets/common/app_card.dart';
import 'package:attendance_app/data/models/leave_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CreateLeavePage extends StatefulWidget {
  const CreateLeavePage({super.key});

  @override
  State<CreateLeavePage> createState() => _CreateLeavePageState();
}

class _CreateLeavePageState extends State<CreateLeavePage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  LeaveTypeModel? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  File? _document;
  String? _documentType;
  List<LeaveTypeModel> _leaveTypes = [];
  int _totalDays = 0;

  @override
  void initState() {
    super.initState();
    context.read<LeaveBloc>().add(const GetLeaveTypesEvent());
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
        _calculateDays();
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      AppSnackbar.showWarning(context, 'Pilih tanggal awal terlebih dahulu');
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _calculateDays();
      });
    }
  }

  void _calculateDays() {
    if (_startDate == null || _endDate == null) return;
    int days = 0;
    DateTime current = _startDate!;
    while (!current.