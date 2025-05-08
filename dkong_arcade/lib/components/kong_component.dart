import "package:flame/components.dart";

class KongComponent extends SpriteComponent {
  KongComponent({required Vector2 position}) : super(position: position, size: Vector2(40, 40));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("images/kong.png");
  }
}

