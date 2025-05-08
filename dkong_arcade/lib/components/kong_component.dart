import "package:flame/components.dart";
import "package:flame/collisions.dart";
import "dart:math" as math;

import "../dkong_game.dart";

class KongComponent extends SpriteComponent with HasGameRef<DonkeyKongFlameGame> {
  // Animation states
  bool isThrowing = false;
  double throwingTime = 0;
  
  KongComponent({required Vector2 position}) 
      : super(position: position, size: Vector2(40, 40)) {
    anchor = Anchor.bottomCenter;
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("kong.png");
    add(RectangleHitbox(
      size: size,
      anchor: Anchor.bottomCenter,
    ));
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Simple animation for barrel throwing
    if (isThrowing) {
      throwingTime += dt;
      if (throwingTime > 0.5) {
        // Reset throwing animation
        isThrowing = false;
        throwingTime = 0;
      }
    }
  }
  
  // Called when kong throws a barrel
  void throwBarrel() {
    isThrowing = true;
    throwingTime = 0;
    
    // Slightly shake kong
    position.x += math.Random().nextDouble() * 4 - 2;
  }
}

