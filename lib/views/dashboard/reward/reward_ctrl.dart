import 'package:get/get.dart';
import 'package:patients/models/reward_model.dart';
import 'package:patients/utils/toaster.dart';
import 'package:patients/views/auth/auth_service.dart';

class RewardCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final RxList<Reward> _availableRewards = <Reward>[].obs;
  final RxList<PatientPointTransaction> _transactions = <PatientPointTransaction>[].obs;

  final RxBool _isLoading = false.obs, _isLoadingMore = false.obs, _isLoadingTransactions = false.obs;
  final RxBool _hasMore = true.obs;
  final RxInt _currentPage = 1.obs, pointsBalance = 0.obs;

  List<Reward> get availableRewards => _availableRewards;

  List<PatientPointTransaction> get transactions => _transactions;

  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get isLoadingTransactions => _isLoadingTransactions.value;
  bool get hasMore => _hasMore.value;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _isLoading.value = true;
    try {
      await Future.wait([loadPointsBalance(), loadRewards(), loadTransactions(reset: true)]);
    } catch (e) {
      toaster.error('Failed to load data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadPointsBalance() async {
    try {
      pointsBalance.value = await _authService.getPointsBalance();
    } catch (e) {
      toaster.error('Failed to load points balance: $e');
    }
  }

  Future<void> loadRewards({bool reset = false}) async {
    try {
      final response = await _authService.getRewards(page: reset ? 1 : _currentPage.value);
      if (response != null && response['docs'] is List) {
        final List newTransactions = response['docs'];
        if (newTransactions.isNotEmpty) {
          final parsedTransactions = newTransactions.map((item) => Reward.fromJson(item)).toList();
          if (reset) {
            _availableRewards.assignAll(parsedTransactions);
          } else {
            _availableRewards.addAll(parsedTransactions);
          }
          final totalPages = response['totalPages'] ?? 1;
          final currentPageNum = response['page'] ?? _currentPage.value;
          _hasMore.value = currentPageNum < totalPages;
          if (_hasMore.value) {
            _currentPage.value = currentPageNum + 1;
          }
        } else {
          _hasMore.value = false;
        }
      } else {
        if (!_isLoadingMore.value) {
          toaster.warning('No rewards found');
        }
        _hasMore.value = false;
      }
    } catch (e) {
      toaster.error('Failed to load rewards: $e');
    }
  }

  Future<void> loadTransactions({bool reset = false}) async {
    if (reset) {
      _isLoadingTransactions.value = true;
    } else {
      _isLoadingMore.value = true;
    }
    try {
      final response = await _authService.getPointHistory(page: reset ? 1 : _currentPage.value);
      if (response != null && response['docs'] is List) {
        final List newTransactions = response['docs'];
        if (newTransactions.isNotEmpty) {
          final parsedTransactions = newTransactions.map((item) => PatientPointTransaction.fromJson(item)).toList();
          if (reset) {
            transactions.assignAll(parsedTransactions);
          } else {
            transactions.addAll(parsedTransactions);
          }
          final totalPages = response['totalPages'] ?? 1;
          final currentPageNum = response['page'] ?? _currentPage.value;
          _hasMore.value = currentPageNum < totalPages;
          if (_hasMore.value) {
            _currentPage.value = currentPageNum + 1;
          }
        } else {
          _hasMore.value = false;
        }
      } else {
        if (!_isLoadingMore.value) {
          toaster.warning('No transactions found');
        }
        _hasMore.value = false;
      }
    } catch (e) {
      toaster.error('Failed to load transactions: $e');
    } finally {
      if (reset) {
        _isLoadingTransactions.value = false;
      } else {
        _isLoadingMore.value = false;
      }
    }
  }

  Future<void> refreshData() async {
    await loadInitialData();
  }

  Future<void> clearAllData() async {
    _availableRewards.clear();
    _transactions.clear();
    _currentPage.value = 1;
    _hasMore.value = true;
    update();
  }
}
