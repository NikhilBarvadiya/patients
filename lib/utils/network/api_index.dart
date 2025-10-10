class APIIndex {
  /// Auth
  static const String register = 'patient/register';
  static const String login = 'patient/login';
  static const String getProfile = 'patient/get-profile';
  static const String updateProfile = 'patient/update-profile';
  static const String updatePassword = 'patient/change-password';

  /// Service
  static const String patientServices = 'services';
  static const String createRequests = 'patient/requests/create';
  static const String getRequests = 'patient/requests/get';
  static const String cancelRequests = 'patient/requests/cancel';
  static const String submitFeedback = 'patient/feedback/submit';
}
