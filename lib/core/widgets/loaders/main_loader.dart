import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:placeholder/core/constants/constants.dart';

class MainLoader extends StatefulWidget {
  const MainLoader({super.key, this.height = 50, this.color});

  final double height;
  final Color? color;

  @override
  State<MainLoader> createState() => _MainLoaderState();
}

class _MainLoaderState extends State<MainLoader> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Trigger the animation on the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //Main Widget
    Widget main = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: _isVisible ? widget.height : 0,
      child: Lottie.asset('assets/loadingLottie.json', height: widget.height),
    );

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        widget.color ?? Constants.colors.primary,
        BlendMode.srcATop,
      ),
      child: Center(child: main),
    );
  }
}
