import "package:flame/components.dart";

class LadderComponent extends SpriteComponent {
  LadderComponent({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("ladder.png");
  }
}

