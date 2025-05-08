import "package:flame/game.dart";
import "package:flame/components.dart";
import "package:flutter/material.dart";
import "components/player_component.dart";
import "components/platform_component.dart";
import "components/ladder_component.dart";
import "components/barrel_component.dart";
import "components/kong_component.dart";
import "components/princess_component.dart";
import "../widgets/dpad.dart";

class DonkeyKongFlameGame extends FlameGame {
  // For input relay
  bool leftDown = false;
  bool rightDown = false;
  bool upDown = false;
  bool downDown = false;
  bool jumpDown = false;

  PlayerComponent? playerRef;

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

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final margin = 24.0;
    final padBottom = 120.0;
    final platformHeight = 16.0;
    // Platforms (bottom to top)
    add(PlatformComponent(
      position: Vector2(margin, size.y - padBottom - platformHeight),
      size: Vector2(size.x - margin * 2, platformHeight),
    ));
    add(PlatformComponent(
      position: Vector2(margin * 2, size.y - padBottom - 70),
      size: Vector2(size.x - margin * 4, platformHeight),
    ));
    add(PlatformComponent(
      position: Vector2(margin, size.y - padBottom - 140),
      size: Vector2(size.x - margin * 2, platformHeight),
    ));
    add(PlatformComponent(
      position: Vector2(margin * 2.5, padBottom + 60),
      size: Vector2(size.x - margin * 5, platformHeight),
    ));
    // Ladders
    add(LadderComponent(position: Vector2(100, size.y - padBottom - 80), size: Vector2(16, 80)));
    add(LadderComponent(position: Vector2(size.x * 0.55, size.y - padBottom - 130), size: Vector2(16, 60)));
    add(LadderComponent(position: Vector2(size.x * 0.7, padBottom + 60), size: Vector2(16, 100)));
    // Player above controls, left
    final player = PlayerComponent()..position = Vector2(margin + 16, size.y - padBottom - 32);
    playerRef = player;
    add(player);
    // DK at the top platform
    add(KongComponent(position: Vector2(margin + 40, padBottom + 9)));
    // Princess at top right
    add(PrincessComponent(position: Vector2(size.x - margin - 40, padBottom + 10)));
    // Initial barrel as placeholder
    add(BarrelComponent(position: Vector2(margin + 100, padBottom + 35)));
  }
}

