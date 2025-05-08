import "package:flame/components.dart";
import "package:flame/collisions.dart";
import "package:flutter/services.dart";
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

  // Physics constants
  final double _moveSpeed = 120.0;
  final double _jumpSpeed = -300.0;
  final double _gravity = 980.0;
  final double _climbSpeed = 80.0;
  double _velocity = 0;
  Vector2 _moveDirection = Vector2.zero();

  PlayerComponent() : super(size: Vector2.all(32)) {
    // Set anchor to bottom center for better platform collision
    anchor = Anchor.bottomCenter;
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
      } else if (gameRef.downDown && !gameRef.upDown) {
        _moveDirection.y = 1;
        state = PlayerState.climbing;
        isOnLadder = true;
      } else if (isOnLadder) {
        // Stop climbing animation when not moving
        _moveDirection.y = 0;
      }
    }

    // Jump only when on ground and not on ladder
    if (gameRef.jumpDown && isOnGround && !isOnLadder) {
      _velocity = _jumpSpeed;
      state = PlayerState.jumping;
      isOnGround = false;
      AudioManager.playJump();
    }

    // Exit ladder if jumping
    if (gameRef.jumpDown && isOnLadder) {
      isOnLadder = false;
      canClimb = false;
      state = PlayerState.jumping;
      _velocity = _jumpSpeed * 0.7; // Reduced jump from ladder
      AudioManager.playJump();
    }

    // Apply horizontal flipping based on direction
    if (facingRight) {
      flipHorizontally = false;
    } else {
      flipHorizontally = true;
    }
  }

  void _applyPhysics(double dt) {
    // Apply gravity when not on ladder
    if (!isOnLadder) {
      _velocity += _gravity * dt;
      
      // Cap falling velocity
      if (_velocity > 500) {
        _velocity = 500;
      }
      
      // Set falling state
      if (_velocity > 0 && !isOnGround) {
        state = PlayerState.falling;
      }
    } else {
      // Reset velocity when on ladder
      _velocity = 0;
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
      position.y += _velocity * dt;
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
    // Check if landing on top of platform (simple collision)
    if (_velocity > 0 && position.y <= platform.position.y) {
      position.y = platform.position.y;
      _velocity = 0;
      isOnGround = true;
      if (state == PlayerState.falling || state == PlayerState.jumping) {
        state = PlayerState.idle;
      }
    }
  }

  void onCollisionWithLadder(LadderComponent ladder) {
    // Determine if player can climb this ladder
    final ladderRect = Rect.fromLTWH(
      ladder.position.x - ladder.width/2, 
      ladder.position.y - ladder.height, 
      ladder.width, 
      ladder.height
    );
    
    final playerRect = Rect.fromLTWH(
      position.x - width/2, 
      position.y - height, 
      width, 
      height
    );
    
    if (ladderRect.overlaps(playerRect)) {
      canClimb = true;
      
      // Center player on ladder when climbing
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
    isOnGround = false;
    isOnLadder = false;
    canClimb = false;
    _velocity = 0;
  }
}

