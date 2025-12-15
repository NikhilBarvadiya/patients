class APIIndex {
  /// Auth
  static const String register = 'patient/register';
  static const String login = 'patient/login';

  /// Verification
  static const String otpSend = 'patient/otp/send';
  static const String otpVerify = 'patient/otp/verify';

  /// Forgot Password
  static const String forgotPassword = 'patient/forgot-password';

  /// Profile
  static const String getProfile = 'patient/get-profile';
  static const String updateProfile = 'patient/update-profile';
  static const String updatePassword = 'patient/change-password';

  /// Rewards
  static const String getRewards = 'rewards';
  static const String getPoints = 'patient/get-points';
  static const String getPointHistory = 'patient/points/history';

  /// Service
  static const String patientServices = 'services';
  static const String createRequests = 'patient/requests/create';
  static const String createPaymentRequests = 'patient/requests/create/payment';
  static const String getRequests = 'patient/requests/get';
  static const String cancelRequests = 'patient/requests/cancel';
  static const String submitFeedback = 'patient/feedback/submit';
}
