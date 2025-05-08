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
    final padBottom = 140.0; // raised from 120
    final platformHeight = 16.0;
    final nLevels = 4;
    final levelSpacing = (size.y - padBottom - 100) / (nLevels - 1);

    // Place platforms (bottom to top)
    List<double> platformYs = List.generate(nLevels, (i) => size.y - padBottom - i * levelSpacing);
    // Zigzag X for platforms
    List<double> platformXs = [margin, size.x * 0.33, margin, size.x * 0.2];
    List<double> platformWidths = [size.x - margin * 2, size.x * 0.6, size.x - margin * 2, size.x * 0.6];
    for (int i = 0; i < nLevels; i++) {
      add(PlatformComponent(
        position: Vector2(platformXs[i], platformYs[i]),
        size: Vector2(platformWidths[i], platformHeight),
      ));
    }
    // Add ladders between platforms, staggered L/R
    add(LadderComponent(position: Vector2(margin + 30, platformYs[1]), size: Vector2(16, levelSpacing)));
    add(LadderComponent(position: Vector2(size.x * 0.8, platformYs[2]), size: Vector2(16, levelSpacing)));
    add(LadderComponent(position: Vector2(margin + 60, platformYs[3]), size: Vector2(16, levelSpacing)));
    // Player: above controls, left on bottom stage
    final player = PlayerComponent()..position = Vector2(margin + 24, platformYs[0] - 32);
    playerRef = player;
    add(player);
    // DK and Princess at top platform
    add(KongComponent(position: Vector2(platformXs[3] + 30, platformYs[3] - 30)));
    add(PrincessComponent(position: Vector2(platformXs[3] + platformWidths[3] - 44, platformYs[3] - 34)));
    // Initial barrel as placeholder
    add(BarrelComponent(position: Vector2(platformXs[2] + 100, platformYs[2] - 15)));
  }
}

