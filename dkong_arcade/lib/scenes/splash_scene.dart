import 'package:flutter/material.dart';

class SplashScene extends StatefulWidget {
  final VoidCallback onContinue;
  const SplashScene({Key? key, required this.onContinue}) : super(key: key);

  @override
  State<SplashScene> createState() => _SplashSceneState();
}

class _SplashSceneState extends State<SplashScene> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
    Future.delayed(const Duration(seconds: 2), widget.onContinue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: FadeTransition(
          opacity: _controller,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sports_esports, size: 90, color: Colors.yellow[600]),
              const SizedBox(height: 16),
              Text(
                "Donkey Kong Arcade",
                style: TextStyle(
                  color: Colors.yellow[600],
                  fontSize: 32,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Flame + Flutter",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 20,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

