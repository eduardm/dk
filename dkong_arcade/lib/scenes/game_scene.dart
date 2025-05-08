import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../dkong_game.dart';
import '../widgets/dpad.dart';
import '../widgets/jump_button.dart';

class GameScene extends StatefulWidget {
  final VoidCallback onGameOver;
  final VoidCallback onVictory;
  const GameScene({Key? key, required this.onGameOver, required this.onVictory}) : super(key: key);

  @override
  State<GameScene> createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> {
  late DonkeyKongFlameGame _game;

  @override
  void initState() {
    super.initState();
    _game = DonkeyKongFlameGame();
  }

  void _handleDPad(DPadDirection dir, bool isPressed) {
    _game.handleDpadInput(dir, isPressed);
  }
  void _handleJump(bool isPressed) {
    _game.handleJumpInput(isPressed);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GameWidget(game: _game),
        // D-Pad (bottom left)
        Positioned(
          left: 0,
          bottom: 0,
          child: DPad(
            onDirectionChanged: _handleDPad,
          ),
        ),
        // Jump button (bottom right)
        Positioned(
          right: 0,
          bottom: 0,
          child: JumpButton(
            onJumpChanged: _handleJump,
          ),
        ),
        // Exit button (top right)
        Positioned(
          top: 36,
          right: 24,
          child: ElevatedButton.icon(
            onPressed: widget.onGameOver,
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

