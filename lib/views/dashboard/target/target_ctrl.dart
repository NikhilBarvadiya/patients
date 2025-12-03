import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patients/models/target_model.dart';
import 'package:patients/utils/toaster.dart';

class TargetCtrl extends GetxController {
  static TargetCtrl get to => Get.find();

  final RxList<Target> _targets = <Target>[].obs;
  final RxString _selectedFilter = 'active'.obs;
  final RxBool _isLoading = false.obs;

  List<Target> get targets => _targets;

  String get selectedFilter => _selectedFilter.value;

  bool get isLoading => _isLoading.value;

  List<Target> get filteredTargets {
    List<Target> result = _targets.where((target) {
      if (selectedFilter == 'active') return target.isActive && !target.isCompleted && !target.isExpired;
      if (selectedFilter == 'completed') return target.isCompleted;
      if (selectedFilter == 'expired') return target.isExpired;
      if (selectedFilter == 'paused') return !target.isActive;
      if (selectedFilter == 'all') return true;
      return target.category == selectedFilter;
    }).toList();
    return result;
  }

  List<Target> get activeTargets => _targets.where((t) => t.isActive && !t.isCompleted && !t.isExpired).toList();

  List<Target> get completedTargets => _targets.where((t) => t.isCompleted).toList();

  @override
  void onInit() {
    super.onInit();
    loadTargets();
  }

  Future<void> loadTargets() async {
    _isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      await _addSampleTargets();
    } catch (e) {
      toaster.error('Failed to load targets: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Map<String, dynamic> getStats() {
    final total = _targets.length;
    final active = activeTargets.length;
    final completed = completedTargets.length;
    final expired = _targets.where((t) => t.isExpired).length;
    final paused = _targets.where((t) => !t.isActive).length;
    double totalProgress = 0;
    if (activeTargets.isNotEmpty) {
      totalProgress = activeTargets.map((t) => t.progress).reduce((a, b) => a + b) / activeTargets.length;
    }
    return {'total': total, 'active': active, 'completed': completed, 'expired': expired, 'paused': paused, 'progress': totalProgress, 'streak': _calculateStreak()};
  }

  int _calculateStreak() {
    if (_targets.isEmpty) return 0;
    final completedDates = _targets.expand((t) => t.completedDates).map((date) => DateTime(date.year, date.month, date.day)).toSet().toList();
    completedDates.sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime currentDate = DateTime.now();
    while (completedDates.contains(DateTime(currentDate.year, currentDate.month, currentDate.day))) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<void> setFilter(String filter) async {
    _selectedFilter.value = filter;
  }

  Future<void> _addSampleTargets() async {
    final sampleTargets = [
      Target(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Daily Steps',
        description: 'Walk 10,000 steps every day for better cardiovascular health',
        currentValue: 7500,
        targetValue: 10000,
        unit: 'steps',
        icon: Icons.directions_walk,
        color: const Color(0xFF4CAF50),
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        frequency: 'daily',
        category: 'fitness',
        completedDates: List.generate(5, (i) => DateTime.now().subtract(Duration(days: i))),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Target(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: 'Water Intake',
        description: 'Drink 2 liters of water daily for hydration',
        currentValue: 1500,
        targetValue: 2000,
        unit: 'ml',
        icon: Icons.local_drink,
        color: const Color(0xFF2196F3),
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 27)),
        frequency: 'daily',
        category: 'nutrition',
        completedDates: [DateTime.now().subtract(const Duration(days: 1))],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Target(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        title: 'Sleep Schedule',
        description: 'Get 8 hours of quality sleep every night',
        currentValue: 7,
        targetValue: 8,
        unit: 'hours',
        icon: Icons.nightlight,
        color: const Color(0xFF9C27B0),
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 23)),
        frequency: 'daily',
        category: 'health',
        completedDates: [DateTime.now().subtract(const Duration(days: 2))],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Target(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        title: 'Weekly Exercise',
        description: 'Complete 5 workout sessions per week',
        currentValue: 3,
        targetValue: 5,
        unit: 'sessions',
        icon: Icons.fitness_center,
        color: const Color(0xFFFF9800),
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        frequency: 'weekly',
        category: 'fitness',
        completedDates: [],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    _targets.assignAll(sampleTargets);
  }
}
