import "package:flame/components.dart";
import "package:flame/collisions.dart";

import "../dkong_game.dart";

class PrincessComponent extends SpriteComponent with HasGameRef<DonkeyKongFlameGame> {
  PrincessComponent({required Vector2 position}) 
      : super(position: position, size: Vector2(28, 36)) {
    anchor = Anchor.bottomCenter;
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("princess.png");
    add(RectangleHitbox(
      size: size,
      anchor: Anchor.bottomCenter,
    ));
  }
}

