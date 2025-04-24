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
import 'package:purchases_flutter/purchases_flutter.dart';

class Paywall extends StatefulWidget {
  const Paywall({super.key});

  @override
  State<Paywall> createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {
  AuthCubit get appCubit => context.read<AuthCubit>();

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    setState(() => loading = true);
    appCubit.getSubscriptions();
    setState(() => loading = false);
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: loading
            ? MainLoader()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Gap(100),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
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
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return Column(
                          children: state.availableSubscriptions
                              .map((e) => PricingOptionCard(
                                  title: toBeginningOfSentenceCase(
                                      e.packageType.name),
                                  description: e.packageType.name == "annual"
                                      ? "Renewed Annually.\nGet 2 Months Free."
                                      : "Renewed every month",
                                  price: e.storeProduct.priceString,
                                  onPressed: () async {
                                    try {
                                      await Purchases.purchasePackage(e);
                                      appCubit.setPro();
                                    } catch (e) {
                                      log("Error purchasing subscription: $e");
                                      snack(context,
                                          "Error purchasing subscription: $e");
                                    }
                                  }))
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
