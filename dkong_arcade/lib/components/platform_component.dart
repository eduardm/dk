import "package:flame/components.dart";

class PlatformComponent extends SpriteComponent {
  PlatformComponent({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("platform.png");
  }
}

