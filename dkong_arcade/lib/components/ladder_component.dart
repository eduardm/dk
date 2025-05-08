import "package:flame/components.dart";
import "package:flame/flame.dart";
import "package:flutter/material.dart" show Colors, Color, Canvas, Paint, Rect, PictureRecorder, ImageByteFormat;

Future<Sprite> fallbackRectSprite(Vector2 size, Color color) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..color = color;
  canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
  final pic = recorder.endRecording();
  final img = await pic.toImage(size.x.toInt(), size.y.toInt());
  final bytes = await img.toByteData(format: ImageByteFormat.png);
  final image = await Flame.images.decodeImageFromList(bytes!.buffer.asUint8List());
  return Sprite(image);
}

class LadderComponent extends SpriteComponent {
  LadderComponent({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    try {
      sprite = await Sprite.load("ladder.png");
    } catch (_) {
      sprite = await fallbackRectSprite(size, Colors.green);
    }
  }
}

