import 'package:flutter/material.dart';

class GameOverScene extends StatelessWidget {
  final VoidCallback onRestart;
  const GameOverScene({Key? key, required this.onRestart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sentiment_very_dissatisfied, size: 80, color: Colors.red[400]),
            const SizedBox(height: 18),
            const Text(
              "Game Over",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

