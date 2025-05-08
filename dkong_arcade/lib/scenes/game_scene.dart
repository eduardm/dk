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
  int _lives = 3;

  @override
  void initState() {
    super.initState();
    _game = DonkeyKongFlameGame();
    
    // Set up callbacks
    _game.setGameOverCallback(widget.onGameOver);
    _game.setVictoryCallback(widget.onVictory);
    
    // Update lives display
    _game.addObserver(() {
      if (_lives != _game.lives) {
        setState(() {
          _lives = _game.lives;
        });
      }
    });
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
        
        // Lives display (top left)
        Positioned(
          top: 20,
          left: 20,
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              Text(
                "× $_lives",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
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
          top: 20,
          right: 20,
          child: ElevatedButton.icon(
            onPressed: widget.onGameOver,
            icon: const Icon(Icons.close),
            label: const Text("Exit"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.7),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    // Clean up game resources
    _game.cleanUp();
    
    // Ensure game is properly cleaned up
    _game.pauseEngine();
    
    super.dispose();
  }
}

