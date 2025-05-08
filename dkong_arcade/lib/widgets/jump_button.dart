import "package:flutter/material.dart";

typedef JumpCallback = void Function(bool isPressed);

class JumpButton extends StatelessWidget {
  final JumpCallback onJumpChanged;
  const JumpButton({Key? key, required this.onJumpChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 22.0, bottom: 32.0),
      child: GestureDetector(
        onTapDown: (_) => onJumpChanged(true),
        onTapUp: (_) => onJumpChanged(false),
        onTapCancel: () => onJumpChanged(false),
        child: Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade400.withOpacity(0.80),
            border: Border.all(width: 2, color: Colors.white60),
          ),
          child: const Center(
            child: Text(
              "JUMP",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                shadows: [
                  Shadow(blurRadius: 1, color: Colors.black, offset: Offset(1, 1)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

