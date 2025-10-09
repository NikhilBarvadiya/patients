class APIIndex {
  /// Auth
  static const String register = 'patient/register'; // done
  static const String login = 'patient/login'; // done
  static const String getProfile = 'patient/get-profile';
  static const String updateProfile = 'patient/update-profile'; // done
  static const String updatePassword = 'patient/change-password'; // done

  /// Service
  static const String patientServices = 'services'; // done
  static const String createRequests = 'patient/requests/create'; // done
  static const String getRequests = 'patient/requests/get'; // done
  static const String cancelRequests = 'patient/requests/cancel'; // done
  static const String submitFeedback = 'patient/feedback/submit'; // done
}
