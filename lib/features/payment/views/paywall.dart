import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/core/usecases/snack.dart';
import 'package:placeholder/core/widgets/loaders/main_loader.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';

class Paywall extends StatefulWidget {
  const Paywall({super.key});

  @override
  State<Paywall> createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {
  AuthCubit get appCubit => context.read<AuthCubit>();
  bool canMakePayments = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    try {
      // canMakePayments = await Purchases.canMakePayments();
      setState(() => loading = true);
      await appCubit.getSubscriptions();
      setState(() => loading = false);
    } catch (e) {
      setState(() => loading = false);
      snack(context, e.toString());
    }
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
                      if (!canMakePayments)
                        Text(
                          "It seems you are not connected to a authorized store. Please contact Support.",
                          style: Constants.textStyles.title2,
                          textAlign: TextAlign.center,
                        ),
                      Gap(20),
                      // BlocBuilder<AuthCubit, AuthState>(
                      //   builder: (context, state) {
                      //     return Column(
                      //       children:
                      //           state.availableSubscriptions
                      //               .map(
                      //                 (e) => PricingOptionCard(
                      //                   title: toBeginningOfSentenceCase(
                      //                     e.packageType.name,
                      //                   ),
                      //                   description:
                      //                       e.packageType.name == "annual"
                      //                           ? "Renewed Annually.\nGet 2 Months Free."
                      //                           : "Renewed every month",
                      //                   price: e.storeProduct.priceString,
                      //                   onPressed: () async {
                      //                     try {
                      //                       await Purchases.purchasePackage(e);
                      //                       appCubit.setPro();
                      //                     } catch (e) {
                      //                       log(
                      //                         "Error purchasing subscription: $e",
                      //                       );
                      //                       snack(
                      //                         context,
                      //                         "Error purchasing subscription: $e",
                      //                       );
                      //                     }
                      //                   },
                      //                 ),
                      //               )
                      //               .toList(),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
      ),
    );
  }
}
