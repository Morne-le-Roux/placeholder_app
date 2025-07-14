import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/core/usecases/snack.dart';
import 'package:placeholder/core/widgets/loaders/main_loader.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/payment/widgets/pricing_option_card.dart';
import 'package:placeholder/services/purchase_service.dart';

class Paywall extends StatefulWidget {
  const Paywall({super.key});

  @override
  State<Paywall> createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {
  AuthCubit get appCubit => context.read<AuthCubit>();
  PurchaseService purchaseService = PurchaseService();

  @override
  void initState() {
    PurchaseService().onPurchasingChanged = (isPurchasing) {
      if (isPurchasing) {
        setState(() => loading = true);
      } else {
        setState(() => loading = false);
      }
    };
    super.initState();
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
            loading
                ? MainLoader()
                : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Expanded(child: SizedBox()),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        width: double.infinity,
                        child: FittedBox(
                          child: Text(
                            "PLACEHOLDER",
                            style: Constants.textStyles.title.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      Text(
                        "Unlock all features and create unlimited tasks.",
                        style: Constants.textStyles.title2,
                        textAlign: TextAlign.center,
                      ),
                      Expanded(child: SizedBox()),
                      if (!purchaseService.isAvailable)
                        Text(
                          "It seems you are not connected to a authorized store. Please contact Support.",
                          style: Constants.textStyles.title2,
                          textAlign: TextAlign.center,
                        ),
                      Gap(20),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return Column(
                            children:
                                purchaseService.products
                                    .map(
                                      (e) => PricingOptionCard(
                                        title: toBeginningOfSentenceCase(
                                          e.title ?? "",
                                        ),
                                        description: e.subtitle ?? "",
                                        price: e.productDetails?.price ?? "",
                                        onPressed: () async {
                                          try {
                                            if (e.productDetails != null) {
                                              purchaseService.buy(
                                                e.productDetails!,
                                              );
                                            }
                                          } catch (e) {
                                            log(
                                              "Error purchasing subscription: $e",
                                            );
                                            snack(
                                              context,
                                              "Error purchasing subscription: $e",
                                            );
                                          }
                                        },
                                      ),
                                    )
                                    .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
