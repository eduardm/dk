import "package:flame/game.dart";
import "package:flame/components.dart";
import "package:flame/collisions.dart";
import "package:flutter/material.dart";
import "dart:async";
import "dart:math" as math;

import "components/player_component.dart";
import "components/platform_component.dart";
import "components/ladder_component.dart";
import "components/barrel_component.dart";
import "components/kong_component.dart";
import "components/princess_component.dart";
import "../widgets/dpad.dart";
import "audio/audio_manager.dart";

class DonkeyKongFlameGame extends FlameGame with HasCollisionDetection {
  // For input relay
  bool leftDown = false;
  bool rightDown = false;
  bool upDown = false;
  bool downDown = false;
  bool jumpDown = false;

  // Game state
  int lives = 3;
  bool gameOver = false;
  bool playerWon = false;
  
  // Callback handlers for game events
  VoidCallback? onGameOver;
  VoidCallback? onVictory;
  
  // Store references to game objects
  PlayerComponent? playerRef;
  KongComponent? kongRef;
  List<PlatformComponent> platforms = [];
  List<LadderComponent> ladders = [];
  List<BarrelComponent> barrels = [];
  
  // Barrel spawning
  Timer? _barrelTimer;
  final double _initialBarrelDelay = 3.0; // seconds
  final double _barrelInterval = 2.5; // seconds
  
  // Player starting position (saved for reset)
  late Vector2 _playerStartPosition;
  
  // Observer pattern for UI updates
  final List<VoidCallback> _observers = [];

  @override
  Color backgroundColor() => const Color(0xFF181622);

  // Called from overlay DPad (public, for GameScene)
  void handleDpadInput(DPadDirection dir, bool isPressed) {
    switch (dir) {
      case DPadDirection.left:
        leftDown = isPressed;
        break;
      case DPadDirection.right:
        rightDown = isPressed;
        break;
      case DPadDirection.up:
        upDown = isPressed;
        break;
      case DPadDirection.down:
        downDown = isPressed;
        break;
    }
  }
  
  // Called from overlay Jump button (public, for GameScene)
  void handleJumpInput(bool isPressed) {
    jumpDown = isPressed;
  }
  
  // Game event handlers
  void setGameOverCallback(VoidCallback callback) {
    onGameOver = callback;
  }
  
  void setVictoryCallback(VoidCallback callback) {
    onVictory = callback;
  }
  
  // Observer pattern methods
  void addObserver(VoidCallback callback) {
    _observers.add(callback);
  }
  
  void removeObserver(VoidCallback callback) {
    _observers.remove(callback);
  }
  
  void _notifyObservers() {
    for (final observer in _observers) {
      observer();
    }
  }
  
  // Player death handling
  void playerDied() {
    lives--;
    _notifyObservers();
    
    if (lives <= 0) {
      gameOver = true;
      AudioManager.playGameOver();
      if (onGameOver != null) {
        onGameOver!();
      }
    } else {
      AudioManager.playBarrelHit();
      // Reset player position
      resetPlayerPosition();
    }
  }
  
  // Victory condition
  void victory() {
    playerWon = true;
    AudioManager.playVictory();
    if (onVictory != null) {
      onVictory!();
    }
  }
  
  // Reset player to starting position
  void resetPlayerPosition() {
    if (playerRef != null) {
      playerRef!.reset(_playerStartPosition);
    }
  }
  
  // Start barrel spawning
  void startBarrelSpawning() {
    _barrelTimer = Timer(
      _initialBarrelDelay,
      onTick: _spawnBarrel,
      repeat: true,
      autoStart: true,
    );
  }
  
  // Spawn a new barrel
  void _spawnBarrel() {
    if (kongRef != null && !gameOver && !playerWon) {
      // Make Kong do the throw animation
      kongRef!.throwBarrel();
      
      // Play barrel roll sound
      AudioManager.playBarrelRoll();
      
      // Create the barrel
      final barrel = BarrelComponent(
        position: Vector2(
          kongRef!.position.x,
          kongRef!.position.y - 20,
        ),
      );
      
      barrels.add(barrel);
      add(barrel);
    }
  }
  
  // Check collisions between player and game objects
  void _checkCollisions() {
    if (playerRef == null) return;
    
    // Reset climbing state each frame
    playerRef!.canClimb = false;
    if (!playerRef!.isOnLadder) {
      playerRef!.isOnGround = false;
    }
    
    // Check platform collisions
    for (final platform in platforms) {
      if (_checkPlayerPlatformCollision(platform)) {
        playerRef!.onCollisionWithPlatform(platform);
      }
    }
    
    // Check ladder collisions
    for (final ladder in ladders) {
      if (_checkPlayerLadderCollision(ladder)) {
        playerRef!.onCollisionWithLadder(ladder);
      }
    }
    
    // Check barrel collisions
    for (final barrel in barrels) {
      if (_checkPlayerBarrelCollision(barrel)) {
        playerRef!.onCollisionWithBarrel(barrel);
      }
    }
    
    // Check princess collision (win condition)
    if (playerRef!.state != PlayerState.dead) {
      final princess = children.whereType<PrincessComponent>().firstOrNull;
      if (princess != null && _checkPlayerPrincessCollision(princess)) {
        playerRef!.onCollisionWithPrincess(princess);
      }
    }
  }
  
  // Helper methods for collision detection
  bool _checkPlayerPlatformCollision(PlatformComponent platform) {
    if (playerRef == null) return false;
    
    final playerFeet = playerRef!.position.y;
    final playerWidth = playerRef!.width;
    final platformY = platform.position.y;
    final platformX = platform.position.x;
    final platformWidth = platform.width;
    
    // Check if player is within horizontal bounds of platform
    final playerCenterX = playerRef!.position.x;
    
    final onPlatformX = playerCenterX >= platformX - platformWidth/2 && 
                        playerCenterX <= platformX + platformWidth/2;
    
    // Check if player is at the right height to land on platform
    // Only allow platform collision when falling (positive velocity)
    final feetNearPlatform = playerFeet >= platformY - 5 && 
                             playerFeet <= platformY + 5 &&
                             !playerRef!.isOnLadder &&
                             playerRef!.state != PlayerState.jumping;
    
    return onPlatformX && feetNearPlatform;
  }
  
  bool _checkPlayerLadderCollision(LadderComponent ladder) {
    if (playerRef == null) return false;
    
    final playerRect = Rect.fromLTWH(
      playerRef!.position.x - playerRef!.width/2,
      playerRef!.position.y - playerRef!.height,
      playerRef!.width,
      playerRef!.height
    );
    
    final ladderRect = Rect.fromLTWH(
      ladder.position.x - ladder.width/2,
      ladder.position.y - ladder.height,
      ladder.width,
      ladder.height
    );
    
    return playerRect.overlaps(ladderRect);
  }
  
  bool _checkPlayerBarrelCollision(BarrelComponent barrel) {
    if (playerRef == null) return false;
    
    final playerRect = Rect.fromLTWH(
      playerRef!.position.x - playerRef!.width/2,
      playerRef!.position.y - playerRef!.height,
      playerRef!.width,
      playerRef!.height
    );
    
    final barrelRect = Rect.fromLTWH(
      barrel.position.x - barrel.width/2,
      barrel.position.y - barrel.height/2,
      barrel.width,
      barrel.height
    );
    
    return playerRect.overlaps(barrelRect);
  }
  
  bool _checkPlayerPrincessCollision(PrincessComponent princess) {
    if (playerRef == null) return false;
    
    final playerRect = Rect.fromLTWH(
      playerRef!.position.x - playerRef!.width/2,
      playerRef!.position.y - playerRef!.height,
      playerRef!.width,
      playerRef!.height
    );
    
    final princessRect = Rect.fromLTWH(
      princess.position.x - princess.width/2,
      princess.position.y - princess.height,
      princess.width,
      princess.height
    );
    
    return playerRect.overlaps(princessRect);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!gameOver && !playerWon) {
      _updateBarrels(dt);
      _checkCollisions();
      
      // Check if player fell off the screen
      if (playerRef != null && playerRef!.position.y > size.y) {
        playerDied();
      }
      
      if (_barrelTimer != null) {
        _barrelTimer!.update(dt);
      }
    }
  }
  
  // Clean up resources
  void cleanUp() {
    if (_barrelTimer != null) {
      _barrelTimer!.stop();
      _barrelTimer = null;
    }
    
    _observers.clear();
    onGameOver = null;
    onVictory = null;
  }
  
  void _updateBarrels(double dt) {
    // Update barrel positions and remove ones that go off-screen
    for (int i = barrels.length - 1; i >= 0; i--) {
      final barrel = barrels[i];
      
      // Check if barrel is off the bottom of the screen
      if (barrel.position.y > size.y) {
        barrel.removeFromParent();
        barrels.removeAt(i);
        continue;
      }
      
      // Determine which platform (if any) the barrel is on
      PlatformComponent? currentPlatform;
      for (final platform in platforms) {
        if (_isBarrelOnPlatform(barrel, platform)) {
          currentPlatform = platform;
          break;
        }
      }
      
      if (currentPlatform != null) {
        // Roll along the platform
        final platformDirection = _getPlatformRollDirection(currentPlatform);
        barrel.position.x += platformDirection * 150 * dt;
        barrel.position.y = currentPlatform.position.y - barrel.height / 2;
      } else {
        // Apply gravity
        barrel.position.y += 300 * dt;
      }
    }
  }
  
  bool _isBarrelOnPlatform(BarrelComponent barrel, PlatformComponent platform) {
    final barrelBottom = barrel.position.y + barrel.height / 2;
    final platformTop = platform.position.y;
    final platformLeft = platform.position.x - platform.width / 2;
    final platformRight = platform.position.x + platform.width / 2;
    
    // More precise platform collision
    return barrel.position.x >= platformLeft &&
           barrel.position.x <= platformRight &&
           barrelBottom >= platformTop - 10 &&  // Increased detection range
           barrelBottom <= platformTop + 10;    // to prevent falling through
  }
  
  int _getPlatformRollDirection(PlatformComponent platform) {
    // Alternate roll direction based on platform Y position
    // This creates the zigzag pattern seen in Donkey Kong
    final platformIndex = platforms.indexOf(platform);
    return platformIndex % 2 == 0 ? 1 : -1;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Initialize audio
    await AudioManager.initialize();
    
    // Reset game state
    lives = 3;
    gameOver = false;
    playerWon = false;
    platforms.clear();
    ladders.clear();
    barrels.clear();
    
    final margin = 24.0;
    final padBottom = 140.0;
    final platformHeight = 16.0;
    final nLevels = 5; // Increase to 5 levels for better gameplay
    final levelSpacing = (size.y - padBottom - 100) / (nLevels - 1);

    // Place platforms (bottom to top)
    List<double> platformYs = List.generate(nLevels, (i) => size.y - padBottom - i * levelSpacing);
    
    // Create proper zigzag pattern for platforms
    List<double> platformXs = [
      margin,                // Bottom platform starts from left
      size.x * 0.25,         // Second platform starts from right side
      margin,                // Third platform starts from left
      size.x * 0.25,         // Fourth platform starts from right
      margin,                // Top platform with princess starts from left
    ];
    
    List<double> platformWidths = [
      size.x - margin * 2,   // Full width for bottom platform
      size.x * 0.7,          // Partial width for second
      size.x * 0.7,          // Partial width for third
      size.x * 0.7,          // Partial width for fourth
      size.x * 0.6,          // Partial width for top platform
    ];
    
    // Create all platforms
    for (int i = 0; i < nLevels; i++) {
      final platform = PlatformComponent(
        position: Vector2(platformXs[i], platformYs[i]),
        size: Vector2(platformWidths[i], platformHeight),
      );
      platforms.add(platform);
      add(platform);
    }
    
    // Add ladders between platforms - ensure they connect properly
    // First ladder - from bottom to second level (left side)
    final ladder1 = LadderComponent(
      position: Vector2(margin + 60, platformYs[0] - levelSpacing), 
      size: Vector2(20, levelSpacing)
    );
    ladders.add(ladder1);
    add(ladder1);
    
    // Second ladder - from second to third level (right side)
    final ladder2 = LadderComponent(
      position: Vector2(platformXs[1] + platformWidths[1] - 60, platformYs[1] - levelSpacing), 
      size: Vector2(20, levelSpacing)
    );
    ladders.add(ladder2);
    add(ladder2);
    
    // Third ladder - from third to fourth level (left side)
    final ladder3 = LadderComponent(
      position: Vector2(margin + 100, platformYs[2] - levelSpacing), 
      size: Vector2(20, levelSpacing)
    );
    ladders.add(ladder3);
    add(ladder3);
    
    // Fourth ladder - from fourth to top level (right side)
    final ladder4 = LadderComponent(
      position: Vector2(platformXs[3] + platformWidths[3] - 80, platformYs[3] - levelSpacing), 
      size: Vector2(20, levelSpacing)
    );
    ladders.add(ladder4);
    add(ladder4);
    
    // Player: starting position on bottom platform
    _playerStartPosition = Vector2(margin + 24, platformYs[0] - 32);
    final player = PlayerComponent()..position = _playerStartPosition.clone();
    playerRef = player;
    add(player);
    
    // Kong at the top left side
    final kong = KongComponent(position: Vector2(platformXs[4] + 40, platformYs[4] - 40));
    kongRef = kong;
    add(kong);
    
    // Princess at the top right side
    add(PrincessComponent(position: Vector2(platformXs[4] + platformWidths[4] - 44, platformYs[4] - 36)));
    
    // Start barrel spawning after a delay
    startBarrelSpawning();
  }
}

