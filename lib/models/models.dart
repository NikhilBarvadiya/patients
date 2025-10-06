import 'package:flutter/material.dart';

class PatientModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String password;
  final String city;
  final String state;
  final String address;

  PatientModel({required this.id, required this.name, required this.email, required this.mobile, required this.password, required this.city, required this.state, required this.address});
}

class TherapistModel {
  final String id;
  final String name;
  final String email;
  final String specialty;
  final int experienceYears;
  final String clinicName;
  final String clinicAddress;
  final double rating;
  final int totalPatients;
  final String? image;
  final Map<String, List<String>>? availability;

  TherapistModel({
    required this.id,
    required this.name,
    required this.email,
    required this.specialty,
    required this.experienceYears,
    required this.clinicName,
    required this.clinicAddress,
    required this.rating,
    required this.totalPatients,
    this.image,
    this.availability,
  });
}

class ServiceModel {
  final int id;
  final String name;
  final String description;
  final IconData icon;
  bool isActive;
  final String therapistId;
  final String therapistName;
  final double price;
  final String duration;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isActive,
    required this.therapistId,
    required this.therapistName,
    required this.price,
    required this.duration,
  });
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
    );
  }
}
