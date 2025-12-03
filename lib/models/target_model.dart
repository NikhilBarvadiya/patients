import 'package:flutter/material.dart';

class Target {
  final String id;
  final String title;
  final String description;
  final double currentValue;
  final double targetValue;
  final String unit;
  final IconData icon;
  final Color color;
  final DateTime startDate;
  final DateTime endDate;
  final String frequency;
  final String category;
  final bool isActive;
  final List<DateTime> completedDates;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Target({
    required this.id,
    required this.title,
    required this.description,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.icon,
    required this.color,
    required this.startDate,
    required this.endDate,
    required this.frequency,
    required this.category,
    this.isActive = true,
    this.completedDates = const [],
    required this.createdAt,
    this.updatedAt,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0;

  int get progressPercentage => (progress * 100).toInt();

  bool get isCompleted => currentValue >= targetValue;

  int get remainingDays => endDate.difference(DateTime.now()).inDays;

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isOnTrack => progress >= 0.7;

  bool get isBehind => progress < 0.4;

  int get streak => completedDates.length;

  bool get canStart => !isActive && !isCompleted && !isExpired;

  bool get canStop => isActive && !isCompleted;

  bool get canRestart => !isActive && !isCompleted && !isExpired;

  bool get isReviewable => isCompleted && completedDates.isNotEmpty;

  DateTime? get lastCompletedDate => completedDates.isNotEmpty ? completedDates.last : null;

  String get status {
    if (isCompleted) return 'Completed';
    if (isExpired) return 'Expired';
    if (!isActive) return 'Paused';
    return 'Active';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'currentValue': currentValue,
    'targetValue': targetValue,
    'unit': unit,
    'icon': icon.codePoint,
    'color': color.value,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'frequency': frequency,
    'category': category,
    'isActive': isActive,
    'completedDates': completedDates.map((e) => e.toIso8601String()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Target.fromJson(Map<String, dynamic> json) => Target(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    currentValue: json['currentValue']?.toDouble() ?? 0.0,
    targetValue: json['targetValue']?.toDouble() ?? 0.0,
    unit: json['unit'],
    icon: IconData(json['icon'] ?? Icons.flag.codePoint, fontFamily: 'MaterialIcons'),
    color: Color(json['color'] ?? Colors.blue.value),
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    frequency: json['frequency'],
    category: json['category'],
    isActive: json['isActive'] ?? true,
    completedDates: (json['completedDates'] as List<dynamic>? ?? []).map((e) => DateTime.parse(e)).toList(),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );
}
