import 'package:flutter/material.dart';
import 'package:placeholder/core/constants/constants.dart';

import '../loaders/main_loader.dart';

class LargeRoundedButton extends StatefulWidget {
  const LargeRoundedButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.isLoading = false,
      this.isValid = true});

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isValid;

  @override
  State<LargeRoundedButton> createState() => _LargeRoundedButtonState();
}

class _LargeRoundedButtonState extends State<LargeRoundedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isValid) {
      setState(() {
        _isShaking = true;
      });
      _shakeController.forward().then((_) {
        _shakeController.reverse().then((_) {
          setState(() {
            _isShaking = false;
          });
        });
      });
    } else {
      widget.onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: widget.isLoading
          ? const MainLoader(key: ValueKey('loader'))
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleTap,
                borderRadius: BorderRadius.circular(50),
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_isShaking ? _shakeAnimation.value : 0, 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        key: const ValueKey('button'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _isShaking
                              ? Constants.colors.error
                              : Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          widget.text,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
