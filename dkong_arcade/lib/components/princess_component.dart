import "package:flame/components.dart";

class PrincessComponent extends SpriteComponent {
  PrincessComponent({required Vector2 position}) : super(position: position, size: Vector2(28, 36));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("princess.png");
  }
}

