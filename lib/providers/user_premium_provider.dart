import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:chess_traps/services/billing_service.dart';

part 'user_premium_provider.g.dart';

@riverpod
class UserPremiumNotifier extends _$UserPremiumNotifier {
  @override
  bool build() {
    _init();
    return false;
  }

  Future<void> _init() async {
    // Initial check
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updateState(customerInfo);
    } catch (e) {
      // Handle error
    }

    // Listen for updates
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _updateState(customerInfo);
    });
  }

  void _updateState(CustomerInfo customerInfo) {
    final entitlements = customerInfo.entitlements.active;
    state = entitlements.containsKey(BillingService.entitlementId);
  }

  Future<void> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateState(customerInfo);
    } catch (e) {
      rethrow;
    }
  }
}
