import "package:flame/components.dart";

class PlayerComponent extends SpriteComponent {
  PlayerComponent() : super(size: Vector2.all(32));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("player.png");
  }
}

