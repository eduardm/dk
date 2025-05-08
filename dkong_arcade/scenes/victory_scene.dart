import 'package:flutter/material.dart';

class VictoryScene extends StatelessWidget {
  final VoidCallback onRestart;
  const VictoryScene({Key? key, required this.onRestart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 80, color: Colors.amberAccent),
            const SizedBox(height: 18),
            const Text(
              "🏆 Victory!",
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text("Play Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[300],
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

