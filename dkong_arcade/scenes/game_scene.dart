import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../dkong_game.dart';

class GameScene extends StatelessWidget {
  final VoidCallback onGameOver;
  final VoidCallback onVictory;
  const GameScene({Key? key, required this.onGameOver, required this.onVictory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GameWidget(game: DonkeyKongFlameGame()),
        Positioned(
          top: 36,
          right: 24,
          child: ElevatedButton.icon(
            onPressed: onGameOver,
            icon: const Icon(Icons.close),
            label: const Text("Exit"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}

