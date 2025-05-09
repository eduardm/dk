import "package:flame/components.dart";
import "package:flame/collisions.dart";

import "../dkong_game.dart";

class LadderComponent extends SpriteComponent with HasGameRef<DonkeyKongFlameGame> {
  LadderComponent({required Vector2 position, required Vector2 size})
      : super(position: position, size: size) {
    // Use center as anchor for consistent positioning
    anchor = Anchor.center;
    
    // Print constructor info for debugging
    print('Creating ladder at $position with size $size');
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("ladder.png");
    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
    ));
  }
}

