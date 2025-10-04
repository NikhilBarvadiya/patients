import 'package:get/get.dart';
import 'package:patients/utils/config/session.dart';
import 'package:patients/utils/storage.dart';

class DashboardCtrl extends GetxController {
  var currentIndex = 0.obs;
  var userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final userData = await read(AppSession.userData);
    if (userData != null) {
      userName.value = userData['name'] ?? userData['clinic'] ?? "Mr. John Smith";
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
