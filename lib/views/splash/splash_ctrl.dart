import 'package:get/get.dart';
import 'package:patients/utils/config/session.dart';
import 'package:patients/utils/routes/route_name.dart';
import 'package:patients/utils/storage.dart';

class SplashCtrl extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    final token = await read(AppSession.token);
    final userData = await read(AppSession.userData);
    if (userData != null && userData["isEmailVerified"] != true) {
      Get.offAllNamed(AppRouteNames.login);
    } else if (token != null && token != "") {
      Get.offAllNamed(AppRouteNames.dashboard);
    } else {
      Get.offAllNamed(AppRouteNames.login);
    }
  }
}
