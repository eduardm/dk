import 'package:flutter/material.dart';

class MenuScene extends StatelessWidget {
  final VoidCallback onStartGame;
  const MenuScene({Key? key, required this.onStartGame}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.yellow[600],
                minimumSize: const Size(180, 50),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                elevation: 8,
              ),
              onPressed: onStartGame,
              icon: const Icon(Icons.play_arrow, size: 32),
              label: const Text("Play"),
            ),
            const SizedBox(height: 40),
            const Text(
              "© Pixel Arcade Demo",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

