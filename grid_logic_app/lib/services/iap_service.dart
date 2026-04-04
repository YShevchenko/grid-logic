// IAP Service - In-App Purchase integration for Grid Logic

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class IAPService {
  static final IAPService instance = IAPService._();
  IAPService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _isInitialized = false;
  bool _adsRemoved = false;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Product IDs
  static const String removeAdsId = 'com.heldig.gridlogic.removeads';

  // Getters
  bool get adsRemoved => _adsRemoved;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('IAP not available on this device');
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Purchase error: $error'),
    );

    // Restore previous purchases
    await _restorePurchases();

    _isInitialized = true;
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _verifyAndDeliverProduct(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void _verifyAndDeliverProduct(PurchaseDetails purchase) {
    if (purchase.productID == removeAdsId) {
      _adsRemoved = true;
      _savePreference('ads_removed', true);
      debugPrint('Product delivered: ${purchase.productID}');
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await _iap.restorePurchases();

      // Also load from local storage
      _adsRemoved = await _loadPreference('ads_removed');
    } catch (e) {
      debugPrint('Restore error: $e');
    }
  }

  // Purchase Methods
  Future<bool> purchaseRemoveAds() async {
    return await _purchaseProduct(removeAdsId);
  }

  Future<bool> _purchaseProduct(String productId) async {
    if (!_isInitialized) {
      debugPrint('IAP not initialized');
      return false;
    }

    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails({productId});

      if (response.productDetails.isEmpty) {
        debugPrint('Product not found: $productId');
        return false;
      }

      final productDetails = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);

      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  Future<Map<String, ProductDetails>> getProductDetails() async {
    const productIds = {removeAdsId};

    final response = await _iap.queryProductDetails(productIds);

    return {
      for (var product in response.productDetails)
        product.id: product
    };
  }

  // Helper methods
  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool> _loadPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
