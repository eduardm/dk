import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'scenes/splash_scene.dart';
import 'scenes/menu_scene.dart';
import 'scenes/game_scene.dart';
import 'scenes/victory_scene.dart';
import 'scenes/gameover_scene.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Force portrait up, immersive mode
  await Flame.device.fullScreen();
  await Flame.device.setPortrait();
  
  // Initialize Flame
  try {
    // Basic initialization - audio will be handled by AudioManager
    await Flame.images.loadAll([
      'player.png',
      'barrel.png',
      'platform.png',
      'kong.png',
      'princess.png',
      'ladder.png',
      'heart.png',
    ]);
  } catch (e) {
    print('Error initializing flame: $e');
  }

  runApp(const DonkeyKongArcadeApp());
}

class DonkeyKongArcadeApp extends StatelessWidget {
  const DonkeyKongArcadeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donkey Kong Arcade',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const DonkeyKongGameRoot(),
    );
  }
}

/// The root widget that holds the active game or overlays.
class DonkeyKongGameRoot extends StatefulWidget {
  const DonkeyKongGameRoot({Key? key}) : super(key: key);

  @override
  State<DonkeyKongGameRoot> createState() => _DonkeyKongGameRootState();
}

class _DonkeyKongGameRootState extends State<DonkeyKongGameRoot> {
  String _scene = 'splash';

  void _switchScene(String sceneName) {
    setState(() {
      _scene = sceneName;
    });
  }

  Widget _getScene() {
    switch(_scene) {
      case 'splash':
        return SplashScene(onContinue: () => _switchScene('menu'));
      case 'menu':
        return MenuScene(
          onStartGame: () => _switchScene('game'),
        );
      case 'game':
        return GameScene(
          onGameOver: () => _switchScene('gameover'),
          onVictory: () => _switchScene('victory'),
        );
      case 'victory':
        return VictoryScene(onRestart: () => _switchScene('menu'));
      case 'gameover':
        return GameOverScene(onRestart: () => _switchScene('menu'));
      default:
        return SplashScene(onContinue: () => _switchScene('menu'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _getScene()),
    );
  }
}

