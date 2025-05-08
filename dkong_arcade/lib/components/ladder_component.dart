import "package:flame/components.dart";
import "package:flame/collisions.dart";

import "../dkong_game.dart";

class LadderComponent extends SpriteComponent with HasGameRef<DonkeyKongFlameGame> {
  LadderComponent({required Vector2 position, required Vector2 size})
      : super(position: position, size: size) {
    anchor = Anchor.center;
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

