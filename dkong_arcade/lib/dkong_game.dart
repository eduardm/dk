import "package:flame/game.dart";
import "package:flame/components.dart";
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
    // Platforms (just 4 platforms for now)
    add(PlatformComponent(position: Vector2(20, size.y - 40), size: Vector2(size.x - 40, 16)));
    add(PlatformComponent(position: Vector2(40, size.y - 120), size: Vector2(size.x - 60, 16)));
    add(PlatformComponent(position: Vector2(20, size.y - 200), size: Vector2(size.x - 40, 16)));
    add(PlatformComponent(position: Vector2(60, 80), size: Vector2(size.x - 120, 16)));
    // Ladders
    add(LadderComponent(position: Vector2(100, size.y - 90), size: Vector2(16, 80)));
    add(LadderComponent(position: Vector2(200, size.y - 170), size: Vector2(16, 80)));
    add(LadderComponent(position: Vector2(250, size.y - 270), size: Vector2(16, 100)));
    // Player starting at bottom left
    final player = PlayerComponent()..position = Vector2(40, size.y - 72);
    playerRef = player;
    add(player);
    // DK at the top platform
    add(KongComponent(position: Vector2(72, 48)));
    // Princess at top right
    add(PrincessComponent(position: Vector2(size.x - 80, 50)));
    // Initial barrel as placeholder
    add(BarrelComponent(position: Vector2(100, 100)));
  }
}

