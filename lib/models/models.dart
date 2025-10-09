
class ReviewModel {
  final String id;
  final String appointmentId;
  final String patientId;
  final String therapistId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? patientName;

  ReviewModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.therapistId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.patientName,
  });

  ReviewModel copyWith({double? rating, String? comment}) {
    return ReviewModel(
      id: id,
      appointmentId: appointmentId,
      patientId: patientId,
      therapistId: therapistId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      patientName: patientName,
    );
  }
}

class PatientRequestModel {
  final String id;
  final String patientId;
  final String therapistId;
  final String serviceName;
  final String serviceId;
  final String date;
  final String time;
  final String status;
  final String patientNotes;
  final DateTime requestedAt;
  final String therapistName;
  final String therapistImage;
  final String duration;
  final double price;
  final ReviewModel? review;

  PatientRequestModel({
    required this.id,
    required this.patientId,
    required this.therapistId,
    required this.serviceName,
    required this.serviceId,
    required this.date,
    required this.time,
    required this.status,
    required this.patientNotes,
    required this.requestedAt,
    required this.therapistName,
    required this.therapistImage,
    required this.duration,
    required this.price,
    this.review,
  });

  PatientRequestModel copyWith({
    String? id,
    String? patientId,
    String? therapistId,
    String? serviceName,
    String? serviceId,
    String? date,
    String? time,
    String? status,
    String? patientNotes,
    DateTime? requestedAt,
    String? therapistName,
    String? therapistImage,
    String? duration,
    double? price,
    ReviewModel? review,
  }) {
    return PatientRequestModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      therapistId: therapistId ?? this.therapistId,
      serviceName: serviceName ?? this.serviceName,
      serviceId: serviceId ?? this.serviceId,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      patientNotes: patientNotes ?? this.patientNotes,
      requestedAt: requestedAt ?? this.requestedAt,
      therapistName: therapistName ?? this.therapistName,
      therapistImage: therapistImage ?? this.therapistImage,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      review: review ?? this.review,
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({required this.id, required this.title, required this.message, required this.type, required this.createdAt, this.isRead = false, this.data});

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(id: id, title: title, message: message, type: type, createdAt: createdAt, isRead: isRead ?? this.isRead, data: data);
  }
}
