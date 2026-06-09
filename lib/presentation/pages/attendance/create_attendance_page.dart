import 'package:attendance_app/presentation/widgets/common/app_snackbar.dart';
import 'package:attendance_app/presentation/widgets/common/app_card.dart';
import 'package:attendance_app/data/models/location_model.dart';
import 'package:attendance_app/data/models/shift_model.dart';
import 'package:attendance_app/core/utils/location_helper.dart';
import 'package:attendance_app/core/utils/camera_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CreateAttendancePage extends StatefulWidget {
  final String? initialType;

  const CreateAttendancePage({super.key, this.initialType});

  @override
  State<CreateAttendancePage> createState() => _CreateAttendancePageState();
}

class _CreateAttendancePageState extends State<CreateAttendancePage> {
  final _notesController = TextEditingController();
  String _selectedType = 'check_in';
  LocationModel? _selectedLocation;
  ShiftModel? _selectedShift;
  File? _capturedPhoto;
  Position? _currentPosition;
  double? _distanceMeter;
  bool _isLoadingLocation = false;
  bool _isWithinRadius = false;
  List<LocationModel> _locations = [];
  List<ShiftModel> _shifts = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
    _loadInitialData();
    _getCurrentLocation();
  }

  Future<void> _loadInitialData() async {
    // Load locations & shifts from API
    // TODO: implement via BLoC
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await LocationHelper.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
      if (_selectedLocation != null) {
        _calculateDistance();
      }
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal mendapatkan lokasi: $e');
      }
    }
  }

  void _calculateDistance() {
    if (_currentPosition == null || _selectedLocation == null) return;

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _selectedLocation!.latitude,
      _selectedLocation!.longitude,
    );

    setState(() {
      _distanceMeter = distance;
      _isWithinRadius = distance <= _selectedLocation!.radius;
    });
  }

  Future<void> _capturePhoto() async {
    final photo = await CameraHelper.captureFromFrontCamera(context);
    if (photo != null) {
      setState(() => _capturedPhoto = photo);
    }
  }

  void _submitAttendance() {
    if (_selectedLocation == null) {
      AppSnackbar.showError(context, 'Pilih lokasi absensi terlebih dahulu');
      return;
    }
    if (_selectedShift == null) {
      AppSnackbar.showError(context, 'Pilih shift terlebih dahulu');
      return;
    }
    if (_capturedPhoto == null) {
      AppSnackbar.showError(context, 'Ambil foto terlebih dahulu');
      return;
    }
    if (_currentPosition == null) {
      AppSnackbar.showError(context, 'Lokasi GPS belum tersedia');
      return;
    }
    if (!_isWithinRadius) {
      AppSnackbar.showError(
        context,
        'Anda berada di luar jangkauan absensi. '
        'Jarak: ${_distanceMeter?.toStringAsFixed(0)}m, '
        'Jangkauan: ${_selectedLocation!.radius}m',
      );
      return;
    }

    context.read<AttendanceBloc>().add(
      CreateAttendanceEvent(
        locationId: _selectedLocation!.id,
        shiftId: _selectedShift!.id,
        type: _selectedType,
        employeeLatitude: _currentPosition!.latitude,
        employeeLongitude: _currentPosition!.longitude,
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
          title: const Text('Tambah Absensi'),
          backgroundColor: AppColors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Attendance Type
              _buildTypeSelector(),
              const SizedBox(height: AppSpacing.lg),

              // Location Selection
              _buildLocationSection(),
              const SizedBox(height: AppSpacing.lg),

              // GPS & Distance Info
              if (_selectedLocation != null) ...[
                _buildLocationInfo(),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Shift Selection
              _buildShiftSection(),
              const SizedBox(height: AppSpacing.lg),

              // Camera Section
              _buildCameraSection(),
              const SizedBox(height: AppSpacing.lg),

              // Notes
              AppTextField(
                controller: _notesController,
                label: 'Catatan (Opsional)',
                hint: 'Tambahkan catatan...',
                prefixIcon: Icons.note_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Submit Button
              BlocBuilder<AttendanceBloc, AttendanceState>(
                builder: (context, state) {
                  return AppButton(
                    label: _selectedType == 'check_in'
                        ? 'Absen Masuk'
                        : 'Absen Keluar',
                    onPressed: _isWithinRadius ? _submitAttendance : null,
                    isLoading: state is AttendanceSubmitting,
                    icon: _selectedType == 'check_in'
                        ? Icons.login_rounded
                        : Icons.logout_rounded,
                    backgroundColor: _isWithinRadius
                        ? (_selectedType == 'check_in'
                            ? AppColors.checkIn
                            : AppColors.checkOut)
                        : AppColors.grey300,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return AppCard(
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
            Icon(icon, color: isSelected ? color : AppColors.grey400, size: 20),
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
              child: Text(
                'Tidak ada lokasi tersedia',
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.grey400,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _locations.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final location = _locations[index];
                final isSelected = _selectedLocation?.id == location.id;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedLocation = location);
                    _calculateDistance();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primarySurface
                          : AppColors.grey50,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.grey200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.grey200,
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.grey500,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location.name,
                                style: AppTextStyles.labelLG.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.grey900,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                location.address,
                                style: AppTextStyles.bodySM,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.radar_rounded,
                                    size: 12,
                                    color: AppColors.grey400,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Jangkauan: ${location.radius}m',
                                    style: AppTextStyles.bodyXS,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Lokasi', style: AppTextStyles.labelLG),
          const SizedBox(height: AppSpacing.md),
          // GPS Status
          _buildInfoRow(
            icon: Icons.gps_fixed_rounded,
            label: 'Koordinat GPS',
            value: _isLoadingLocation
                ? 'Mendapatkan lokasi...'
                : _currentPosition != null
                    ? '${_currentPosition!.latitude.toStringAsFixed(6)}, '
                        '${_currentPosition!.longitude.toStringAsFixed(6)}'
                    : 'Tidak tersedia',
            color: _currentPosition != null
                ? AppColors.success
                : AppColors.error,
            isLoading: _isLoadingLocation,
          ),
          const Divider(height: AppSpacing.lg),
          // Office Coordinate
          _buildInfoRow(
            icon: Icons.business_rounded,
            label: 'Koordinat Kantor',
            value: '${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                '${_selectedLocation!.longitude.toStringAsFixed(6)}',
            color: AppColors.grey700,
          ),
          const Divider(height: AppSpacing.lg),
          // Distance
          _buildInfoRow(
            icon: Icons.social_distance_rounded,
            label: 'Jarak ke Kantor',
            value: _distanceMeter != null
                ? '${_distanceMeter!.toStringAsFixed(0)} meter'
                : 'Menghitung...',
            color: _isWithinRadius ? AppColors.success : AppColors.error,
          ),
          const Divider(height: AppSpacing.lg),
          // Radius
          _buildInfoRow(
            icon: Icons.radar_rounded,
            label: 'Jangkauan Absensi',
            value: '${_selectedLocation!.radius} meter',
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          // Status Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: _isWithinRadius
                  ? AppColors.successLight
                  : AppColors.errorLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isWithinRadius
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: _isWithinRadius
                      ? AppColors.success
                      : AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _isWithinRadius
                      ? 'Anda berada dalam jangkauan absensi'
                      : 'Anda berada di luar jangkauan absensi',
                  style: AppTextStyles.labelMD.copyWith(
                    color: _isWithinRadius
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Refresh Location Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _getCurrentLocation,
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                _isLoadingLocation
                    ? 'Memperbarui lokasi...'
                    : 'Perbarui Lokasi GPS',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLoading = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySM),
              const SizedBox(height: 2),
              if (isLoading)
                const SizedBox(
                  width: 120,
                  height: 14,
                  child: AppLoading(),
                )
              else
                Text(
                  value,
                  style: AppTextStyles.labelMD.copyWith(color: color),
                ),
            ],
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
          if (_shifts.isEmpty)
            Center(
              child: Text(
                'Tidak ada shift tersedia',
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.grey400,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _shifts.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final shift = _shifts[index];
                final isSelected = _selectedShift?.id == shift.id;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedShift = shift),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primarySurface
                          : AppColors.grey50,
                      borderRadius:
                          BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.grey200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shift.name,
                                style: AppTextStyles.labelLG.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.grey900,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: AppColors.grey400,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    '${shift.checkInTime} - ${shift.checkOutTime}',
                                    style: AppTextStyles.bodySM,
                                  ),
                                  if (shift.lateTolerance > 0) ...[
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      '(Toleransi: ${shift.lateTolerance}m)',
                                      style: AppTextStyles.bodyXS.copyWith(
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                );
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
          Text('Foto Absensi', style: AppTextStyles.labelLG),
          const SizedBox(height: AppSpacing.md),
          if (_capturedPhoto == null)
            GestureDetector(
              onTap: _capturePhoto,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.grey200,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_front_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Ambil Foto Selfie',
                      style: AppTextStyles.labelLG.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Gunakan kamera depan untuk foto absensi',
                      style: AppTextStyles.bodySM,
                    ),
                  ],
                ),
              ),
            )
          else
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.file(
                    _capturedPhoto!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: GestureDetector(
                    onTap: _capturePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 14,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Foto berhasil diambil',
                          style: AppTextStyles.bodyXS.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
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
    super.dispose();
  }
}