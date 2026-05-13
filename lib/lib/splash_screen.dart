import 'dart:math';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import '../currency_converter.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3800,
      splashIconSize: 650,
      backgroundColor: const Color(0xff020617),
      splashTransition: SplashTransition.fadeTransition,
      nextScreen: const CurrencyConverter(),
      splash: const PremiumSplashContent(),
    );
  }
}

class PremiumSplashContent extends StatefulWidget {
  const PremiumSplashContent({super.key});

  @override
  State<PremiumSplashContent> createState() => _PremiumSplashContentState();
}

class _PremiumSplashContentState extends State<PremiumSplashContent>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();

    animation = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double value = animation.value;

        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.85 + (value * 0.15),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _CurrencySymbol(text: "\$", top: 35, left: 40, value: value),
                _CurrencySymbol(text: "€", top: 90, right: 35, value: value),
                _CurrencySymbol(text: "₹", bottom: 95, left: 45, value: value),
                _CurrencySymbol(text: "¥", bottom: 45, right: 55, value: value),

                Container(
                  width: 315,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 34,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.25),
                        blurRadius: 45,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: Offset(0, sin(controller.value * 2 * pi) * 8),
                        child: Container(
                          height: 185,
                          width: 185,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xff38BDF8),
                                Color(0xff2563EB),
                                Color(0xff8B5CF6),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.45),
                                blurRadius: 35,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Image.asset(
                              "assets/image/splash_screen.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Currency Converter",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Real-time exchange rates",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 32),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: LinearProgressIndicator(
                          value: controller.value,
                          minHeight: 6,
                          backgroundColor: Colors.white24,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        "Loading...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CurrencySymbol extends StatelessWidget {
  final String text;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double value;

  const _CurrencySymbol({
    required this.text,
    required this.value,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Opacity(
        opacity: 0.25 * value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
