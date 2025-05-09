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
      
      // Create the barrel at Kong's position
      final barrel = BarrelComponent(
        position: Vector2(
          kongRef!.position.x,
          kongRef!.position.y + 20, // Adjust position to be below Kong
        ),
      );
      
      // Find the platform Kong is on to place barrel correctly
      if (platforms.isNotEmpty && platforms.length >= 4) {
        // Use the top platform (platform index 3)
        final topPlatform = platforms[3];
        barrel.position.y = topPlatform.position.y - topPlatform.height/2 - barrel.height/2;
      }
      
      barrels.add(barrel);
      add(barrel);
      
      print("Spawned barrel at ${barrel.position}");
    }
  }
  
  // Check collisions between player and game objects
  void _checkCollisions() {
    if (playerRef == null) return;
    
    // Reset climbing state each frame
    playerRef!.canClimb = false;
    
    // Only reset isOnGround if not climbing a ladder and not already on a platform
    if (!playerRef!.isOnLadder) {
      // We'll temporarily set this to false, and the platform collision check will set it back to true
      bool wasOnGround = playerRef!.isOnGround;
      playerRef!.isOnGround = false;
      
      // Check platform collisions - this will set isOnGround to true if on a platform
      bool foundPlatform = false;
      for (final platform in platforms) {
        if (_checkPlayerPlatformCollision(platform)) {
          playerRef!.onCollisionWithPlatform(platform);
          foundPlatform = true;
        }
      }
      
      // If we just fell off a platform, immediately set falling state
      if (wasOnGround && !playerRef!.isOnGround && playerRef!.state != PlayerState.jumping) {
        playerRef!.state = PlayerState.falling;
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
    
    // Get player's feet position (bottom center of sprite)
    final playerFeet = playerRef!.position.y;
    
    // Get platform position (center of sprite)
    final platformY = platform.position.y;
    final platformTop = platformY - platform.height / 2;
    final platformX = platform.position.x;
    final platformWidth = platform.width;
    
    // Player's horizontal position (center)
    final playerCenterX = playerRef!.position.x;
    
    // Check if player is within horizontal bounds of platform
    final onPlatformX = playerCenterX >= platformX - platformWidth/2 && 
                        playerCenterX <= platformX + platformWidth/2;
    
    // Print debug info to understand positions
    print('Player feet Y: $playerFeet, Platform top Y: $platformTop');
    print('Player velocity: ${playerRef!.velocity}');
    
    // Check if player is at the right height to land on platform
    // Player must be falling (positive velocity) to land
    final feetNearPlatform = playerFeet >= platformTop - 2 && 
                             playerFeet <= platformTop + 2 &&
                             playerRef!.velocity >= 0 &&  // Must be falling
                             !playerRef!.isOnLadder;
    
    // Set player on ground if collision detected
    if (onPlatformX && feetNearPlatform) {
      playerRef!.position.y = platformTop;
      playerRef!.velocity = 0;
      playerRef!.isOnGround = true;
      return true;
    }
    
    return false;
  }
  
  bool _checkPlayerLadderCollision(LadderComponent ladder) {
    if (playerRef == null) return false;
    
    // Get player's rectangle (centered on player's position)
    final playerRect = Rect.fromLTWH(
      playerRef!.position.x - playerRef!.width/2,
      playerRef!.position.y - playerRef!.height,
      playerRef!.width,
      playerRef!.height
    );
    
    // Get ladder's rectangle (centered on ladder's position)
    final ladderRect = Rect.fromLTWH(
      ladder.position.x - ladder.width/2,
      ladder.position.y - ladder.height/2,
      ladder.width,
      ladder.height
    );
    
    // Print ladder position for debugging
    print('Ladder pos: ${ladder.position}, Player pos: ${playerRef!.position}');
    print('Ladder height: ${ladder.height}, Player height: ${playerRef!.height}');
    
    // Check if player overlaps with ladder
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
        barrel.position.x += platformDirection * 180 * dt; // Increased speed
        
        // Keep barrel on top of platform
        barrel.position.y = currentPlatform.position.y - currentPlatform.height/2 - barrel.height/2;
        
        // Check if barrel reached platform edge
        final platformLeft = currentPlatform.position.x - currentPlatform.width/2;
        final platformRight = currentPlatform.position.x + currentPlatform.width/2;
        
        if (barrel.position.x < platformLeft + 10 || barrel.position.x > platformRight - 10) {
          // Barrel falls off platform
          barrel.position.y += 5; // Start falling
        }
      } else {
        // Apply gravity (faster falling)
        barrel.position.y += 350 * dt;
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
    // Get platform index
    final platformIndex = platforms.indexOf(platform);
    
    // If platform not found, default to right
    if (platformIndex < 0) return 1;
    
    // Determine direction based on platform index
    // Floor 1 (index 0) - roll right
    // Floor 2 (index 1) - roll left 
    // Floor 3 (index 2) - roll right
    // Floor 4 (index 3) - roll left
    switch (platformIndex) {
      case 0: return 1;  // bottom - right
      case 1: return -1; // 2nd - left
      case 2: return 1;  // 3rd - right
      case 3: return -1; // top - left
      default: return platformIndex % 2 == 0 ? 1 : -1; // fallback
    }
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
    
    // Simple level design with 4 floors in a zigzag pattern
    final margin = 20.0;
    final platformHeight = 20.0;
    final screenHeight = size.y;
    final screenWidth = size.x;
    final bottomPadding = 140.0;
    
    // Calculate level positions (4 levels, evenly spaced)
    final levelCount = 4;
    final levelSpacing = (screenHeight - bottomPadding - 80) / (levelCount - 1);
    
    // Floor Y positions (bottom to top)
    List<double> floorYs = List.generate(
      levelCount, 
      (i) => screenHeight - bottomPadding - i * levelSpacing
    );
    
    // Create platforms with alternate directions
    // Floor 1 (bottom) - full width
    final platform1 = PlatformComponent(
      position: Vector2(screenWidth / 2, floorYs[0]),
      size: Vector2(screenWidth - margin * 2, platformHeight),
    );
    platforms.add(platform1);
    add(platform1);
    
    // Floor 2 - right side to center  
    final platform2 = PlatformComponent(
      position: Vector2(screenWidth * 0.65, floorYs[1]),
      size: Vector2(screenWidth * 0.7 - margin, platformHeight),
    );
    platforms.add(platform2);
    add(platform2);
    
    // Floor 3 - left side to center
    final platform3 = PlatformComponent(
      position: Vector2(screenWidth * 0.35, floorYs[2]),
      size: Vector2(screenWidth * 0.7 - margin, platformHeight),
    );
    platforms.add(platform3);
    add(platform3);
    
    // Floor 4 (top) - center
    final platform4 = PlatformComponent(
      position: Vector2(screenWidth / 2, floorYs[3]),
      size: Vector2(screenWidth * 0.5 - margin, platformHeight),
    );
    platforms.add(platform4);
    add(platform4);
    
    // Create ladders to connect platforms
    // Ladder 1 - connects floor 1 to floor 2 (left side)
    final ladder1 = LadderComponent(
      position: Vector2(screenWidth * 0.3, (floorYs[0] + floorYs[1]) / 2),
      size: Vector2(40, floorYs[0] - floorYs[1] - platformHeight),
    );
    ladders.add(ladder1);
    add(ladder1);
    
    // Ladder 2 - connects floor 2 to floor 3 (right side)
    final ladder2 = LadderComponent(
      position: Vector2(screenWidth * 0.7, (floorYs[1] + floorYs[2]) / 2),
      size: Vector2(40, floorYs[1] - floorYs[2] - platformHeight),
    );
    ladders.add(ladder2);
    add(ladder2);
    
    // Ladder 3 - connects floor 3 to floor 4 (left side)
    final ladder3 = LadderComponent(
      position: Vector2(screenWidth * 0.3, (floorYs[2] + floorYs[3]) / 2),
      size: Vector2(40, floorYs[2] - floorYs[3] - platformHeight),
    );
    ladders.add(ladder3);
    add(ladder3);
    
    // Player starting position on bottom platform
    _playerStartPosition = Vector2(margin + 40, floorYs[0] - platformHeight/2);
    final player = PlayerComponent()..position = _playerStartPosition.clone();
    playerRef = player;
    add(player);
    
    // Kong at left side of top platform
    final kong = KongComponent(
      position: Vector2(screenWidth / 2 - 60, floorYs[3] - platformHeight/2 - 20)
    );
    kongRef = kong;
    add(kong);
    
    // Princess at right side of top platform
    add(PrincessComponent(
      position: Vector2(screenWidth / 2 + 60, floorYs[3] - platformHeight/2 - 18)
    ));
    
    // Start barrel spawning after a delay
    startBarrelSpawning();
  }
}

