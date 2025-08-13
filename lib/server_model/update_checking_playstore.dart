import 'package:app/server_model/remote_config_service.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionChecker {
  Future<void> checkAppVersion(BuildContext context) async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      } else {
        debugPrint("✅ App is up-to-date");
      }
    } catch (e) {
      debugPrint("❌ Error checking update: $e");
    }
  }
}
