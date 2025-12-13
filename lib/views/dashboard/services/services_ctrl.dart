import 'package:get/get.dart';
import 'package:patients/utils/toaster.dart';
import 'package:patients/views/auth/auth_service.dart';
import '../../../models/service_model.dart';

class ServicesCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var services = <ServiceModel>[].obs, filteredServices = <ServiceModel>[].obs;
  var isLoading = false.obs, isLoadMoreLoading = false.obs, hasMore = true.obs;
  var currentPage = 1.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices({bool loadMore = false}) async {
    if (isLoading.value) return;
    try {
      if (!loadMore) {
        isLoading.value = true;
        currentPage.value = 1;
        hasMore.value = true;
        services.clear();
        filteredServices.clear();
      } else {
        if (!hasMore.value || isLoadMoreLoading.value) return;
        isLoadMoreLoading.value = true;
      }
      final response = await _authService.patientServices(page: currentPage.value, search: searchQuery.value);
      if (response != null && response['docs'] is List) {
        final List newServices = response['docs'];
        if (newServices.isNotEmpty) {
          final parsedServices = newServices.map((item) => ServiceModel.fromJson(item)).toList();
          if (loadMore) {
            services.addAll(parsedServices);
          } else {
            services.assignAll(parsedServices);
          }
          filteredServices.assignAll(services);
          final totalPages = response['totalPages'] ?? 1;
          final currentPageNum = response['currentPage'] ?? currentPage.value;
          hasMore.value = currentPageNum < totalPages;
          if (hasMore.value) {
            currentPage.value = currentPageNum + 1;
          }
        } else {
          hasMore.value = false;
        }
      } else {
        if (!loadMore) {
          toaster.warning("'No services found'");
        }
        hasMore.value = false;
      }
    } catch (e) {
      if (!loadMore) {
        toaster.error(e.toString());
      }
    } finally {
      isLoading.value = false;
      isLoadMoreLoading.value = false;
      update();
    }
  }

  void searchServices(String query) {
    searchQuery.value = query.trim();
    debounce<String>(searchQuery, (_) => loadServices(), time: const Duration(milliseconds: 500));
  }

  void loadMoreServices() {
    if (hasMore.value && !isLoading.value && !isLoadMoreLoading.value) {
      loadServices(loadMore: true);
    }
  }

  Future<void> refreshServices() async => await loadServices();

  void clearSearch() {
    searchQuery.value = '';
    loadServices();
  }
}
