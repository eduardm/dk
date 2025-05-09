import "package:flame/components.dart";
import "package:flame/collisions.dart";
import "package:flutter/services.dart";
import "package:flutter/material.dart" show Canvas;
import "dart:math" as math;

import "../dkong_game.dart";
import "platform_component.dart";
import "ladder_component.dart";
import "barrel_component.dart";
import "princess_component.dart";
import "../audio/audio_manager.dart";

enum PlayerState { idle, walking, jumping, climbing, falling, dead }

class PlayerComponent extends SpriteComponent with HasGameRef<DonkeyKongFlameGame>, CollisionCallbacks {
  PlayerState state = PlayerState.idle;
  bool facingRight = true;
  bool isOnGround = false;
  bool isOnLadder = false;
  bool canClimb = false;
  
  // Custom rendering to handle flipping
  @override
  void render(Canvas canvas) {
    if (sprite == null) return;
    
    // Save canvas state
    canvas.save();
    
    // Apply flip transformation if needed
    if (!facingRight) {
      // Flip horizontally
      final centerX = position.x;
      canvas.scale(-1, 1); // Flip horizontally
      canvas.translate(-2 * centerX, 0); // Adjust position after flipping
    }
    
    // Now call the parent render method
    super.render(canvas);
    
    // Restore canvas state
    canvas.restore();
  }

  // Physics constants
  final double _moveSpeed = 120.0;
  final double _jumpSpeed = -300.0;
  final double _gravity = 980.0;
  final double _climbSpeed = 80.0;
  // Make velocity public for collision handling
  double velocity = 0;
  Vector2 _moveDirection = Vector2.zero();

  PlayerComponent() : super(size: Vector2.all(32)) {
    // Set anchor to bottom center for better platform collision
    anchor = Anchor.bottomCenter;
    
    // Start with player on the ground
    isOnGround = true;
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("player.png");
    add(RectangleHitbox(
      position: Vector2(0, -size.y),
      size: size,
      anchor: Anchor.bottomLeft,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _handleInput();
    _applyPhysics(dt);
    _updatePosition(dt);
    _checkBoundaries();
  }

  void _handleInput() {
    // Reset move direction
    _moveDirection = Vector2.zero();

    // Handle left/right movement
    if (gameRef.leftDown && !gameRef.rightDown) {
      _moveDirection.x = -1;
      facingRight = false;
      if (isOnGround && state != PlayerState.jumping) {
        state = PlayerState.walking;
      }
    } else if (gameRef.rightDown && !gameRef.leftDown) {
      _moveDirection.x = 1;
      facingRight = true;
      if (isOnGround && state != PlayerState.jumping) {
        state = PlayerState.walking;
      }
    } else if (isOnGround && state != PlayerState.jumping) {
      state = PlayerState.idle;
    }

    // Handle vertical ladder movement
    if (canClimb) {
      if (gameRef.upDown && !gameRef.downDown) {
        _moveDirection.y = -1;
        state = PlayerState.climbing;
        isOnLadder = true;
        print("Climbing UP");
      } else if (gameRef.downDown && !gameRef.upDown) {
        _moveDirection.y = 1;
        state = PlayerState.climbing;
        isOnLadder = true;
        print("Climbing DOWN");
      } else if (isOnLadder) {
        // Stop climbing animation when not moving
        _moveDirection.y = 0;
      }
    }
    
    // Print debug info
    if (canClimb) {
      print("Can climb: $canClimb, Is on ladder: $isOnLadder, Direction: $_moveDirection");
    }

    // Jump only when on ground and not on ladder
    if (gameRef.jumpDown && isOnGround && !isOnLadder) {
      velocity = _jumpSpeed;
      state = PlayerState.jumping;
      isOnGround = false;
      AudioManager.playJump();
    }

    // Exit ladder if jumping
    if (gameRef.jumpDown && isOnLadder) {
      isOnLadder = false;
      canClimb = false;
      state = PlayerState.jumping;
      velocity = _jumpSpeed * 0.7; // Reduced jump from ladder
      AudioManager.playJump();
    }

    // Apply horizontal flipping based on direction
    if (!facingRight) {
      // Use render() override for flipping in a complete implementation
      // For now, we'll just keep track of direction
      // In a full implementation, we would use sprite flipping
    }
  }

  void _applyPhysics(double dt) {
    // Apply gravity when not on ladder
    if (!isOnLadder) {
      velocity += _gravity * dt;
      
      // Cap falling velocity
      if (velocity > 500) {
        velocity = 500;
      }
      
      // Set falling state
      if (velocity > 0 && !isOnGround) {
        state = PlayerState.falling;
      }
    } else {
      // Reset velocity when on ladder
      velocity = 0;
    }
  }

  void _updatePosition(double dt) {
    // Apply horizontal movement
    if (!isOnLadder || (isOnLadder && _moveDirection.y == 0)) {
      position.x += _moveDirection.x * _moveSpeed * dt;
    }

    // Apply climbing movement
    if (isOnLadder) {
      position.y += _moveDirection.y * _climbSpeed * dt;
    } else {
      // Apply vertical velocity (jumping/falling)
      position.y += velocity * dt;
    }
  }

  void _checkBoundaries() {
    // Keep player within the screen bounds
    if (position.x < 0) {
      position.x = 0;
    } else if (position.x > gameRef.size.x) {
      position.x = gameRef.size.x;
    }
    
    // Prevent climbing past the top of a ladder
    if (isOnLadder && position.y < 0) {
      position.y = 0;
    }
    
    // Reset climbing state if not in contact with a ladder
    if (!canClimb && isOnLadder) {
      isOnLadder = false;
    }
  }

  void onCollisionWithPlatform(PlatformComponent platform) {
    // Now handled in _checkPlayerPlatformCollision
    // Simply update state
    if (isOnGround) {
      if (state == PlayerState.falling || state == PlayerState.jumping) {
        state = PlayerState.idle;
      }
    }
  }

  void onCollisionWithLadder(LadderComponent ladder) {
    // Use simpler collision detection for ladders
    final playerCenterX = position.x;
    final playerBottom = position.y;
    final playerTop = position.y - height;
    
    final ladderTop = ladder.position.y - ladder.height/2;
    final ladderBottom = ladder.position.y + ladder.height/2;
    final ladderCenterX = ladder.position.x;
    final ladderWidth = ladder.width;
    
    // Check if player and ladder overlap horizontally
    final horizontalOverlap = (playerCenterX - width/2 <= ladderCenterX + ladderWidth/2) && 
                              (playerCenterX + width/2 >= ladderCenterX - ladderWidth/2);
    
    // Check if player and ladder overlap vertically
    final verticalOverlap = (playerBottom >= ladderTop) && (playerTop <= ladderBottom);
    
    final nearLadder = horizontalOverlap && verticalOverlap;
    
    // Print debug info
    print("Player near ladder: $nearLadder (H: $horizontalOverlap, V: $verticalOverlap)");
    print("Ladder pos: (${ladder.position.x}, ${ladder.position.y}), size: ${ladder.width}x${ladder.height}");
    print("Player pos: (${position.x}, ${position.y}), size: ${width}x${height}");
    
    if (nearLadder) {
      // Allow climbing
      canClimb = true;
      
      // Begin climbing if up/down pressed
      if ((gameRef.upDown || gameRef.downDown) && !isOnLadder) {
        isOnLadder = true;
        state = PlayerState.climbing;
        position.x = ladder.position.x; // Center on ladder
        
        // Ensure we're not stuck in a platform by moving player slightly
        if (gameRef.upDown) {
          position.y -= 5; // Move up slightly to get off platform
        }
      }
      
      // Keep player centered on ladder while climbing
      if (isOnLadder) {
        position.x = ladder.position.x;
      }
    }
  }

  void onCollisionWithBarrel(BarrelComponent barrel) {
    final barrelRect = Rect.fromLTWH(
      barrel.position.x - barrel.width/2, 
      barrel.position.y - barrel.height/2, 
      barrel.width, 
      barrel.height
    );
    
    final playerRect = Rect.fromLTWH(
      position.x - width/2, 
      position.y - height, 
      width, 
      height
    );

    if (barrelRect.overlaps(playerRect)) {
      die();
    }
  }

  void onCollisionWithPrincess(PrincessComponent princess) {
    final princessRect = Rect.fromLTWH(
      princess.position.x - princess.width/2, 
      princess.position.y - princess.height, 
      princess.width, 
      princess.height
    );
    
    final playerRect = Rect.fromLTWH(
      position.x - width/2, 
      position.y - height, 
      width, 
      height
    );

    if (princessRect.overlaps(playerRect)) {
      gameRef.victory();
    }
  }

  void die() {
    if (state != PlayerState.dead) {
      state = PlayerState.dead;
      gameRef.playerDied();
    }
  }

  // Reset player state when restarting
  void reset(Vector2 position) {
    this.position = position;
    state = PlayerState.idle;
    facingRight = true;
    isOnGround = true; // Start on ground
    isOnLadder = false;
    canClimb = false;
    velocity = 0;
  }
}

