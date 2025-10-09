class PatientRequestModel {
  String id;
  String patient;
  Service service;
  String preferredType;
  int charge;
  String status;
  int rating;
  List<Doctor> doctors;
  DateTime requestedAt;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  String cancelledBy;
  String feedback;

  PatientRequestModel({
    required this.id,
    required this.patient,
    required this.service,
    required this.preferredType,
    required this.charge,
    required this.status,
    required this.rating,
    required this.doctors,
    required this.requestedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.cancelledBy,
    required this.feedback,
  });

  factory PatientRequestModel.fromJson(Map<String, dynamic> json) {
    return PatientRequestModel(
      id: json['_id'] ?? '',
      patient: json['patient'] ?? '',
      service: Service.fromJson(json['service'] ?? {}),
      preferredType: json['preferredType'] ?? 'Regular',
      charge: json['charge'] ?? 0,
      status: json['status'] ?? 'Pending',
      rating: json['rating'] ?? 0,
      doctors: (json['doctors'] as List? ?? []).map((doctor) => Doctor.fromJson(doctor)).toList(),
      requestedAt: DateTime.parse(json['requestedAt'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      v: json['__v'] ?? 0,
      cancelledBy: json['cancelledBy'] ?? '',
      feedback: json['feedback'] ?? '',
    );
  }

  String get serviceName => service.name;

  double get price => charge.toDouble();

  String get therapistName => doctors.isNotEmpty ? 'Dr. ${doctors.first.doctorId}' : 'Doctor not assigned';

  String get patientNotes => feedback;
}

class Doctor {
  String doctorId;
  int rating;
  bool isSend;
  String fcmToken;
  String id;

  Doctor({required this.doctorId, required this.rating, required this.isSend, required this.fcmToken, required this.id});

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(doctorId: json['id'] ?? '', rating: json['rating'] ?? 0, isSend: json['isSend'] ?? false, fcmToken: json['fcmToken'] ?? '', id: json['_id'] ?? '');
  }
}

class Service {
  String id;
  String name;
  int charge;
  int lowCharge;
  int highCharge;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  Service({
    required this.id,
    required this.name,
    required this.charge,
    required this.lowCharge,
    required this.highCharge,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      charge: json['charge'] ?? 0,
      lowCharge: json['lowCharge'] ?? 0,
      highCharge: json['highCharge'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      v: json['__v'] ?? 0,
    );
  }
}
