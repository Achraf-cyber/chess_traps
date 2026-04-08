import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class BillingService {
  static const sdkKey = 'test_EszBxGlSguSLKRpktjKIACyLxoE';
  static const entitlementId = 'ChessTrapsApp Pro';

  static Future<void> init() async {
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(sdkKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(sdkKey);
    } else {
      return;
    }

    await Purchases.configure(configuration);
  }

  static Future<void> presentPaywallIfNeeded() async {
    try {
      await RevenueCatUI.presentPaywallIfNeeded(entitlementId);
    } catch (e) {
      debugPrint('Error presenting paywall: $e');
    }
  }

  static Future<void> showPaywall() async {
    try {
      await RevenueCatUI.presentPaywall();
    } catch (e) {
      debugPrint('Error presenting paywall: $e');
    }
  }

  static Future<void> showCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('Error presenting customer center: $e');
    }
  }

  /// Restores previous purchases.
  static Future<CustomerInfo> restorePurchases() async {
    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      rethrow;
    }
  }
}
