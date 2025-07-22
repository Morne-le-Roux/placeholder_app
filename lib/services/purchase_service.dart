// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:placeholder/main.dart';

PackageInfo? packageInfo;

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  String subId = "co.za.disnetdev.placeholder.pro";

  Duration verificationInterval = Duration(days: 7);

  List<PurchasableProduct> products = [];
  bool isAvailable = false;

  // after a purchase or check, basePlanId is set.
  String? currentBasePlan;

  /// Callback to notify UI of loading state
  void Function(bool)? onPurchasingChanged;

  /// Callback to run on a purchase success
  Future<void> Function()? _onPurchaseSuccess;

  // Initialize on app startup
  Future<void> init() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) return;

    packageInfo = await PackageInfo.fromPlatform();

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        debugPrint('Purchase Stream Error: $error');
        onPurchasingChanged?.call(false);
      },
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    Set<String> kIds = {subId};
    List<GooglePlayProductDetails> subGooglePlayProductDetails = [];
    List<ProductDetails> normalProducts = [];

    final ProductDetailsResponse response = await _iap.queryProductDetails(
      kIds,
    );
    subGooglePlayProductDetails.addAll(
      response.productDetails
          .where((test) => test.id == subId)
          .map((e) => e as GooglePlayProductDetails),
    );
    normalProducts.addAll(
      response.productDetails.where((test) => test.id != subId),
    );

    if (response.error != null) {
      debugPrint('Product query error: ${response.error}');
      return;
    }

    final sbResponse = await sb.from("products").select();

    for (var i = 0; i < sbResponse.length; i++) {
      PurchasableProduct purchasableProduct = PurchasableProduct.fromJson(
        sbResponse[i],
      );
      if (purchasableProduct.id == "monthly" ||
          purchasableProduct.id == "annual") {
        GooglePlayProductDetails? googlePlayProductDetail =
            subGooglePlayProductDetails.firstWhereOrNull(
              (product) =>
                  product
                      .productDetails
                      .subscriptionOfferDetails?[product.subscriptionIndex ?? 0]
                      .basePlanId ==
                  purchasableProduct.id,
            );
        purchasableProduct.productDetails =
            googlePlayProductDetail as ProductDetails;
      } else {
        purchasableProduct.productDetails = normalProducts.firstWhereOrNull(
          (test) => test.id == purchasableProduct.id,
        );
      }
      products.add(purchasableProduct);
    }
  }

  /// Buy a consumable product
  Future<void> buyConsumable(
    ProductDetails product, {
    Future<void> Function()? onSuccess,
  }) async {
    _onPurchaseSuccess = onSuccess;
    onPurchasingChanged?.call(true);
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyConsumable(purchaseParam: purchaseParam);
  }

  void buySubscription(
    ProductDetails product, {
    Future<void> Function()? onSuccess,
  }) {
    _onPurchaseSuccess = onSuccess;
    onPurchasingChanged?.call(true);
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Complete purchase if in pending
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }

        // Check if this is a subscription or consumable
        if (purchase.productID == subId) {
          // Subscription: verify purchase and get basePlanId from backend
          final String? basePlanId = await _getBasePlanIfValid(purchase);
          if (basePlanId != null) {
            currentBasePlan = basePlanId;
            if (_onPurchaseSuccess != null) {
              await _onPurchaseSuccess!();
              _onPurchaseSuccess = null;
            }
          } else {
            debugPrint("❌ Invalid purchase detected! Not granting access.");
            throw "Error with purchase verification. Please contact support.";
          }
        } else {
          // Consumable: grant item, no backend verification
          debugPrint('✅ Consumable purchased: ${purchase.productID}');
          if (_onPurchaseSuccess != null) {
            await _onPurchaseSuccess!();
            _onPurchaseSuccess = null;
          }
        }
        onPurchasingChanged?.call(false);
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('Purchase failed: ${purchase.error}');
        onPurchasingChanged?.call(false);
      }
    }
  }

  Future<String?> isUserPro({
    ///When the app should check again if the user's sub is active.
    String? nextProCheck,

    ///What the old planId was for the user.
    String? activeSubscription,
  }) async {
    bool shouldCheck = true;
    if (nextProCheck != null) {
      DateTime? nextProCheckDateTime = DateTime.tryParse(nextProCheck)?.toUtc();
      DateTime now = DateTime.now().toUtc();
      if (nextProCheckDateTime != null) {
        if (nextProCheckDateTime.isAfter(now)) {
          shouldCheck = false;
        }
      }
    }

    if (!shouldCheck) {
      log("Skipping pro_check");
      currentBasePlan = activeSubscription;
      return activeSubscription;
    }
    log("Checking Pro Status");

    if (!isAvailable) {
      return null;
    }

    final List<PurchaseDetails> allPurchases = [];

    final sub = InAppPurchase.instance.purchaseStream.listen((purchases) {
      allPurchases.addAll(purchases);
    });

    await InAppPurchase.instance.restorePurchases();
    await Future.delayed(Duration(seconds: 1));
    await sub.cancel();

    for (final purchase in allPurchases) {
      if (purchase.status == PurchaseStatus.pending) {
        await _iap.completePurchase(purchase);
      }
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == subId) {
          String? basePlanId = await _getBasePlanIfValid(purchase);
          currentBasePlan = basePlanId;
        }
      }
    }

    bool isPro = currentBasePlan != null;
    if (sb.auth.currentUser != null) {
      await sb
          .from("profiles")
          .update({
            "is_pro": isPro,
            'active_subscription': currentBasePlan,
            "next_pro_check":
                isPro == true
                    ? DateTime.now()
                        .add(verificationInterval)
                        .toUtc()
                        .toString()
                    : null,
          })
          .eq('id', sb.auth.currentUser!.id);
    }
    return currentBasePlan;
  }

  void dispose() {
    _subscription.cancel();
  }
}

Future<String?> _getBasePlanIfValid(PurchaseDetails purchase) async {
  try {
    final res = await sb.functions.invoke(
      'verify_purchase',
      body: {
        'platform':
            defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        'purchaseToken': purchase.verificationData.serverVerificationData,
        'productId': purchase.productID,
        'packageName': packageInfo?.packageName,
        'receiptData':
            purchase.verificationData.serverVerificationData, // iOS only
      },
    );

    final data = res.data is String ? jsonDecode(res.data) : res.data;
    final basePlanId = data['basePlanId'];

    debugPrint('🔍 Purchase verification result — basePlanId: $basePlanId');
    return basePlanId;
  } catch (e) {
    debugPrint('❌ Error verifying purchase: $e');
    rethrow;
  }
}

class PurchasableProduct {
  PurchasableProduct({
    required this.id,
    this.title,
    this.subtitle,
    required this.type,
    this.productDetails,
  });

  final String id;
  final String? title;
  final String? subtitle;
  final ProductType type;
  ProductDetails? productDetails;

  PurchasableProduct copyWith({
    String? id,
    String? title,
    String? subtitle,
    ProductType? type,
    ProductDetails? productDetails,
  }) {
    return PurchasableProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      productDetails: productDetails ?? this.productDetails,
    );
  }

  factory PurchasableProduct.fromJson(Map<String, dynamic> map) {
    String? typeInString = map['type'];
    ProductType? type;
    if (typeInString != null) {
      switch (typeInString.toLowerCase()) {
        case "sub":
          type = ProductType.sub;
          break;
        case "product":
          type = ProductType.product;
        default:
          type = ProductType.product;
      }
    }
    return PurchasableProduct(
      id: map['id'] as String,
      title: map['title'] != null ? map['title'] as String : null,
      type: type ?? ProductType.product,
      subtitle: map['subtitle'] != null ? map['subtitle'] as String : null,
    );
  }
}

enum ProductType { sub, product }
