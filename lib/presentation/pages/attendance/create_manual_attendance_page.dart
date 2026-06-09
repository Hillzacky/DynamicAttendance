import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_app/core/theme/app_theme.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_bloc.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_event.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_state.dart';
import 'package:attendance_app/presentation/widgets/common/app_button.dart';
import 'package:attendance_app/presentation/widgets/common/app_text_field.dart';
import 'package:attendance_app/presentation/widgets/common/app_snackbar.dart';
import 'package:attendance_app/presentation/widgets/common/app_card.dart';
import 'package:attendance_app/data/models/location_model.dart';
import 'package:attendance_app/data/models/shift_model.dart';
import 'package:attendance_app/core/utils/camera_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CreateManualAttendancePage extends StatefulWidget {
  const CreateManualAttendancePage({super.key});

  @override
  State<CreateManualAttendancePage> createState() =>
      _CreateManualAttendancePageState();
}

class _CreateManualAttendancePageState
    extends State<CreateManualAttendancePage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _reasonController = TextEditingController();
  String _selectedType = 'check_in';
  LocationModel? _selectedLocation;
  ShiftModel? _selectedShift;
  File? _capturedPhoto;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<LocationModel> _locations = [];
  List<ShiftModel> _shifts = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Load from API via BLoC
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _capturePhoto() async {
    final photo = await CameraHelper.captureFromFrontCamera(context);
    if (photo != null) {
      setState(() => _capturedPhoto = photo);
    }
  }

  void _submitManualAttendance() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocation == null) {
      AppSnackbar.showError(context, 'Pilih lokasi absensi terlebih dahulu');
      return;
    }
    if (_selectedShift == null) {
      AppSnackbar.showError(context, 'Pilih shift terlebih dahulu');
      return;
    }
    if (_reasonController.text.isEmpty) {
      AppSnackbar.showError(context, 'Alasan absensi manual wajib diisi');
      return;
    }

    final manualDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final manualTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    context.read<AttendanceBloc>().add(
      CreateManualAttendanceEvent(
        locationId: _selectedLocation!.id,
        shiftId: _selectedShift!.id,
        type: _selectedType,
        manualDate: manualDate,
        manualTime: manualTime,
        manualReason: _reasonController.text,
        photo: _capturedPhoto,
        notes: _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceCreateSuccess) {
          AppSnackbar.showSuccess(context, state.message);
          context.pop();
        } else if (state is AttendanceFailure) {
          AppSnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.grey50,
        appBar: AppBar(
          title: const Text('Absensi Manual'),
          backgroundColor: AppColors.white,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Absensi manual memerlukan persetujuan admin',
                          style: AppTextStyles.bodySM.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Attendance Type
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tipe Absensi', style: AppTextStyles.labelLG),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeOption(
                              type: 'check_in',
                              label: 'Masuk',
                              icon: Icons.login_rounded,
                              color: AppColors.checkIn,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildTypeOption(
                              type: 'check_out',
                              label: 'Keluar',
                              icon: Icons.logout_rounded,
                              color: AppColors.checkOut,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Date & Time Selection
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal & Jam', style: AppTextStyles.labelLG),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  border: Border.all(
                                      color: AppColors.grey200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tanggal',
                                          style: AppTextStyles.bodyXS,
                                        ),
                                        Text(
                                          DateFormat('dd MMM yyyy')
                                              .format(_selectedDate),
                                          style: AppTextStyles.labelLG,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectTime,
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  border: Border.all(
                                      color: AppColors.grey200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Jam',
                                          style: AppTextStyles.bodyXS,
                                        ),
                                        Text(
                                          _selectedTime.format(context),
                                          style: AppTextStyles.labelLG,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Location Section (same as create attendance)
                _buildLocationSection(),
                const SizedBox(height: AppSpacing.lg),

                // Shift Section
                _buildShiftSection(),
                const SizedBox(height: AppSpacing.lg),

                // Camera Section
                _buildCameraSection(),
                const SizedBox(height: AppSpacing.lg),

                // Reason Field (Required)
                AppTextField(
                  controller: _reasonController,
                  label: 'Alasan Absensi Manual *',
                  hint: 'Jelaskan alasan absensi manual...',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alasan wajib diisi';
                    }
                    if (value.length < 10) {
                      return 'Alasan minimal 10 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Notes Field (Optional)
                AppTextField(
                  controller: _notesController,
                  label: 'Catatan (Opsional)',
                  hint: 'Tambahkan catatan...',
                  prefixIcon: Icons.note_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Submit Button (No radius restriction)
                BlocBuilder<AttendanceBloc, AttendanceState>(
                  builder: (context, state) {
                    return AppButton(
                      label: 'Kirim Absensi Manual',
                      onPressed: _submitManualAttendance,
                      isLoading: state is AttendanceSubmitting,
                      icon: Icons.send_rounded,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required String type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.grey50,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? color : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? color : AppColors.grey400, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.labelLG.copyWith(
                color: isSelected ? color : AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lokasi Absensi', style: AppTextStyles.labelLG),
          const SizedBox(height: AppSpacing.md),
          if (_locations.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.location_off_rounded,
                    color: AppColors.grey300,
                    size: 40,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tidak ada lokasi tersedia',
                    style: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.grey400,
                    ),
                  ),
                ],
              ),
            )
          else
            DropdownButtonFormField<LocationModel>(
              value: _selectedLocation,
              hint: const Text('Pilih lokasi absensi'),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.grey400,
                ),
                filled: true,
                fillColor: AppColors.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.grey200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.grey200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              items: _locations
                  .map((location) => DropdownMenuItem(
                        value: location,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              location.name,
                              style: AppTextStyles.labelMD,
                            ),
                            Text(
                              location.address,
                              style: AppTextStyles.bodyXS,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (location) {
                setState(() => _selectedLocation = location);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildShiftSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Shift', style: AppTextStyles.labelLG),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<ShiftModel>(
            value: _selectedShift,
            hint: const Text('Pilih shift kerja'),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.schedule_rounded,
                color: AppColors.grey400,
              ),
              filled: true,
              fillColor: AppColors.grey50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            items: _shifts
                .map((shift) => DropdownMenuItem(
                      value: shift,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            shift.name,
                            style: AppTextStyles.labelMD,
                          ),
                          Text(
                            '${shift.checkInTime} - ${shift.checkOutTime}',
                            style: AppTextStyles.bodyXS.copyWith(
                              color: AppColors.grey500,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (shift) {
              setState(() => _selectedShift = shift);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCameraSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Foto Absensi (Opsional)', style: AppTextStyles.labelLG),
          const SizedBox(height: AppSpacing.md),
          if (_capturedPhoto == null)
            OutlinedButton.icon(
              onPressed: _capturePhoto,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              icon: const Icon(Icons.camera_front_rounded),
              label: const Text('Ambil Foto Selfie'),
            )
          else
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.file(
                    _capturedPhoto!,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: AppColors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _capturedPhoto = null),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: AppColors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}