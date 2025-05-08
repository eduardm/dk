import "package:flame/components.dart";
import "package:flame/collisions.dart";
import "dart:math" as math;

import "../dkong_game.dart";

class BarrelComponent extends SpriteComponent with HasGameRef<DonkeyKongFlameGame> {
  // Barrel rolling properties
  double rollSpeed = 0;
  bool isRolling = false;

  BarrelComponent({required Vector2 position}) 
      : super(position: position, size: Vector2(24, 24)) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("barrel.png");
    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Add rotation effect for rolling barrels
    angle += dt * 3; // simple rotation effect
    
    // Check if barrel is off screen
    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
  }
}

