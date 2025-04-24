import 'package:flutter/material.dart';
import 'package:placeholder/core/constants/constants.dart';

class PricingOptionCard extends StatelessWidget {
  const PricingOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String price;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        margin: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Constants.textStyles.title2,
                  ),
                  Text(
                    description,
                    style: Constants.textStyles.title3,
                  ),
                ],
              ),
            ),
            Text(price, style: Constants.textStyles.title2),
          ],
        ),
      ),
    );
  }
}
