class Reward {
  final String id;
  final String title;
  final String description;
  final int points;
  final dynamic service;
  final dynamic equipment;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.service,
    this.equipment,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAvailable => isActive;

  Map<String, dynamic> toJson() => {'_id': id, 'title': title, 'description': description, 'points': points, 'service': service, 'equipment': equipment, 'isActive': isActive};

  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
    id: json['_id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    points: json['points'] ?? 0,
    service: json['service'],
    equipment: json['equipment'],
    isActive: json['isActive'] ?? true,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
  );
}

class PatientPointTransaction {
  final String id;
  final String patientId;
  final int points;
  final String type; // 'Credit' or 'Debit'
  final String description;
  final int balanceAfter;
  final String? addedBy;
  final String source; // 'Admin' or 'System'
  final DateTime createdAt;
  final DateTime updatedAt;

  PatientPointTransaction({
    required this.id,
    required this.patientId,
    required this.points,
    required this.type,
    required this.description,
    required this.balanceAfter,
    this.addedBy,
    this.source = 'Admin',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCredit => type == 'Credit';

  bool get isDebit => type == 'Debit';

  Map<String, dynamic> toJson() => {
    '_id': id,
    'patientId': patientId,
    'points': points,
    'type': type,
    'description': description,
    'balanceAfter': balanceAfter,
    'addedBy': addedBy,
    'source': source,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory PatientPointTransaction.fromJson(Map<String, dynamic> json) => PatientPointTransaction(
    id: json['_id'] ?? '',
    patientId: json['patientId'] ?? '',
    points: json['points'] ?? 0,
    type: json['type'] ?? 'Credit',
    description: json['description'] ?? '',
    balanceAfter: json['balanceAfter'] ?? 0,
    addedBy: json['addedBy'],
    source: json['source'] ?? 'Admin',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
  );
}
