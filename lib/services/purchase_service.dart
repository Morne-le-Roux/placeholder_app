// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:placeholder/main.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  static const String monthlySubId = "monthly";
  static const String annualSubId = "annual";
  String subId = "co.za.disnetdev.placeholder.pro";

  List<PurchasableProduct> products = [];
  bool isAvailable = false;

  /// Callback to notify UI of loading state
  void Function(bool)? onPurchasingChanged;

  // Initialize on app startup
  Future<void> init() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) return;

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
    List<GooglePlayProductDetails> googlePlayProductDetails = [];

    final ProductDetailsResponse response = await _iap.queryProductDetails(
      kIds,
    );
    googlePlayProductDetails.addAll(
      response.productDetails.map((e) => e as GooglePlayProductDetails),
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
      GooglePlayProductDetails? googlePlayProductDetail =
          googlePlayProductDetails.firstWhereOrNull(
            (product) =>
                product
                    .productDetails
                    .subscriptionOfferDetails?[product.subscriptionIndex ?? 0]
                    .basePlanId ==
                purchasableProduct.id,
          );
      if (googlePlayProductDetail != null) {
        purchasableProduct.productDetails =
            googlePlayProductDetail as ProductDetails;
      }
      products.add(purchasableProduct);
    }
  }

  void buy(ProductDetails product) {
    onPurchasingChanged?.call(true);
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        await _processPurchase(purchase);
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        onPurchasingChanged?.call(false);
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('Purchase failed: ${purchase.error}');
        onPurchasingChanged?.call(false);
      }
    }
  }

  Future<void> _processPurchase(PurchaseDetails purchase) async {
    final String productId = purchase.productID;

    bool isPro = await isUserPro();

    // final DateTime now = DateTime.now();
    // late DateTime expiry;

    // switch (productId) {
    //   case monthlySubId:
    //     expiry = now.add(Duration(days: 30));
    //     break;
    //   case annualSubId:
    //     expiry = now.add(Duration(days: 365));
    //     break;
    //   default:
    //     return;
    // }

    // final userId = sb.auth.currentUser!.id;

    // await sb
    //     .from('profiles')
    //     .update({'is_pro': true, 'pro_expiry_date': expiry.toIso8601String()})
    //     .eq('id', userId);
  }

  Future<bool> isUserPro() async {
    final Completer<bool> completer = Completer<bool>();
    final List<PurchaseDetails> allPurchases = [];

    final sub = InAppPurchase.instance.purchaseStream.listen((purchases) {
      allPurchases.addAll(purchases);
    });

    await InAppPurchase.instance.restorePurchases();
    await Future.delayed(Duration(seconds: 1));
    await sub.cancel();

    final now = DateTime.now();

    for (final purchase in allPurchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        final transactionDate = DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(purchase.transactionDate ?? '') ?? 0,
        );

        final isMonthly = purchase.productID == monthlySubId;
        final isAnnual = purchase.productID == annualSubId;

        final expiry =
            isMonthly
                ? transactionDate.add(Duration(days: 30))
                : isAnnual
                ? transactionDate.add(Duration(days: 365))
                : transactionDate;

        if (now.isBefore(expiry)) {
          completer.complete(true);
          break;
        }
      }
    }

    if (!completer.isCompleted) completer.complete(false);
    return completer.future;
  }

  void dispose() {
    _subscription.cancel();
  }
}

class PurchasableProduct {
  PurchasableProduct({
    required this.id,
    this.title,
    this.subtitle,
    this.productDetails,
  });

  final String id;
  final String? title;
  final String? subtitle;
  ProductDetails? productDetails;

  PurchasableProduct copyWith({
    String? id,
    String? title,
    String? subtitle,
    ProductDetails? productDetails,
  }) {
    return PurchasableProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      productDetails: productDetails ?? this.productDetails,
    );
  }

  factory PurchasableProduct.fromJson(Map<String, dynamic> map) {
    return PurchasableProduct(
      id: map['id'] as String,
      title: map['title'] != null ? map['title'] as String : null,
      subtitle: map['subtitle'] != null ? map['subtitle'] as String : null,
    );
  }
}
