class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://localhost:3000/api/v1';
  static const String uploadsUrl = 'http://localhost:3000/uploads';

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String verifyToken = '/auth/verify';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Users
  static const String users = '/users';
  static const String profile = '/users/profile';
  static const String userStatistics = '/users/statistics';

  // Attendances
  static const String attendances = '/attendances';
  static const String attendanceToday = '/attendances/today';
  static const String attendanceCalendar = '/attendances/calendar';
  static const String attendanceStatistics = '/attendances/statistics';
  static const String attendanceManual = '/attendances/manual';

  // Leaves
  static const String leaves = '/leaves';
  static const String leaveCalendar = '/leaves/calendar';
  static const String leaveTypes = '/leaves/types';

  // Locations
  static const String locations = '/locations';

  // Shifts
  static const String shifts = '/shifts';

  // Clients
  static const String clients = '/clients';

  // Departments
  static const String departments = '/departments';
  static const String positions = '/departments/positions/list';
}