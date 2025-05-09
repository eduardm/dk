import "package:flame/components.dart";
import "package:flame/collisions.dart";

import "../dkong_game.dart";

class PlatformComponent extends SpriteComponent with HasGameRef<DonkeyKongFlameGame> {
  PlatformComponent({required Vector2 position, required Vector2 size})
      : super(position: position, size: size) {
    // Use center as anchor for consistent positioning
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("platform.png");
    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
    ));
  }
}

