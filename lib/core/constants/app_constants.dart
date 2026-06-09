class AppConstants {
  // App Info
  static const String appName = 'Attendance App';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String deviceIdKey = 'device_id';
  static const String onboardingKey = 'onboarding_done';

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  // Location
  static const int locationTimeout = 10; // seconds
  static const int locationAccuracy = 10; // meters

  // Camera
  static const double maxImageWidth = 800;
  static const double maxImageHeight = 800;
  static const int imageQuality = 80;

  // Animation Duration
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd MMMM yyyy';
  static const String displayDateTimeFormat = 'dd MMM yyyy, HH:mm';
  static const String displayTimeFormat = 'HH:mm';

  // Attendance
  static const List<String> attendanceStatus = [
    'present', 'late', 'early_leave',
    'absent', 'pending', 'approved', 'rejected',
  ];

  // Leave Types Code
  static const String annualLeave = 'ANNUAL_LEAVE';
  static const String sickLeave = 'SICK_LEAVE';
  static const String maternityLeave = 'MATERNITY_LEAVE';
  static const String paternityLeave = 'PATERNITY_LEAVE';
  static const String bereavementLeave = 'BEREAVEMENT_LEAVE';
  static const String marriageLeave = 'MARRIAGE_LEAVE';

  // Leave Status
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String cancelled = 'cancelled';

  // Attendance Type
  static const String checkIn = 'check_in';
  static const String checkOut = 'check_out';

  // Attendance Mode
  static const String current = 'current';
  static const String manual = 'manual';

  // User Role
  static const String superadmin = 'superadmin';
  static const String admin = 'admin';
  static const String hr = 'hr';
  static const String employee = 'employee';

  // User Status
  static const String active = 'active';
  static const String inactive = 'inactive';
  static const String suspended = 'suspended';
  static const String resigned = 'resigned';
}