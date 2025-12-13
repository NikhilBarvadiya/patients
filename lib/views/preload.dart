import 'package:get/get.dart';
import 'package:patients/utils/service/location_service.dart';
import 'package:patients/views/auth/auth_service.dart';

Future<void> preload() async {
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => LocationService().init());
}
