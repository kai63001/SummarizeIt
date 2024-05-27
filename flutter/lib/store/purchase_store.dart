import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseStore extends Cubit<Map<String, dynamic>> {
  PurchaseStore() : super({});

  Future<void> initPurchaseStore() async {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      EntitlementInfo? activeEntitlement = customerInfo.entitlements.all['pro'];
      bool isPro = false;
      if (activeEntitlement != null) {
        isPro = activeEntitlement.isActive;
      }
      String originalAppUserId = customerInfo.originalAppUserId;
      emit({'isPro': isPro, 'originalAppUserId': originalAppUserId});
    });
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('recordingList');
    emit({});
  }
}
