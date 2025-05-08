import "package:flame/components.dart";

class BarrelComponent extends SpriteComponent {
  BarrelComponent({required Vector2 position}) : super(position: position, size: Vector2(24, 24));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("barrel.png");
  }
}

