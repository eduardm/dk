import 'package:flutter/material.dart';

enum DPadDirection { up, down, left, right }

typedef DPadCallback = void Function(DPadDirection direction, bool isPressed);

class DPad extends StatelessWidget {
  final DPadCallback onDirectionChanged;
  final bool showUp;
  final bool showDown;
  const DPad({Key? key, required this.onDirectionChanged, this.showUp = true, this.showDown = true})
      : super(key: key);

  Widget _buildButton(BuildContext context, DPadDirection dir, IconData icon, {double size = 40.0}) {
    return GestureDetector(
      onTapDown: (_) => onDirectionChanged(dir, true),
      onTapUp: (_) => onDirectionChanged(dir, false),
      onTapCancel: () => onDirectionChanged(dir, false),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 14, bottom: 9),
          child: Column(
            children: [
              if (showUp) _buildButton(context, DPadDirection.up, Icons.keyboard_arrow_up),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton(context, DPadDirection.left, Icons.keyboard_arrow_left),
                  const SizedBox(width: 16),
                  _buildButton(context, DPadDirection.right, Icons.keyboard_arrow_right),
                ],
              ),
              if (showDown) _buildButton(context, DPadDirection.down, Icons.keyboard_arrow_down),
            ],
          ),
        )
      ],
    );
  }
}

