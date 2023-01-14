import 'package:flutter/material.dart';
import '../models/keyboard_control_mode.dart';

class KeyboardControl extends StatefulWidget {
  final Function(int keyCode) sendCommand;

  const KeyboardControl({Key? key, required this.sendCommand})
      : super(key: key);

  @override
  State<KeyboardControl> createState() => _KeyboardControlState();
}

class _KeyboardControlState extends State<KeyboardControl> {
  bool _isPressed = false;

  List<Widget> _getTextKeyBlocks(
      List<String> keys, Color color, double textSize) {
    return List<Widget>.generate(
        keys.length,
        (index) => Container(
              width: 100,
              height: 100,
              decoration:
                  BoxDecoration(color: color, border: Border.all(width: 1)),
              child: GestureDetector(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: color),
                    onPressed: () {
                      widget.sendCommand(
                          KeyboardControlMode.getKeyCode(keys[index]));
                    },
                    child: Center(
                        child: Text(keys[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: textSize)))),
                onLongPressStart: (_) async {
                  _isPressed = true;
                  do {
                    widget.sendCommand(
                        KeyboardControlMode.getKeyCode(keys[index]));
                    await Future.delayed(
                        const Duration(milliseconds: 100), () {});
                  } while (_isPressed);
                },
                onLongPressEnd: (_) => setState(() => _isPressed = false),
              ),
            ));
  }

  List<Widget> _getIconKeyBlocks(
      List<String> keys, Color color, double iconSize) {
    return List<Widget>.generate(
        keys.length,
        (index) => Container(
              width: 90,
              height: 90,
              decoration:
                  BoxDecoration(color: color, border: Border.all(width: 1)),
              child: GestureDetector(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: color),
                    onPressed: () {
                      widget.sendCommand(
                          KeyboardControlMode.getKeyCode(keys[index]));
                    },
                    child: Icon(
                        size: iconSize,
                        KeyboardControlMode.getIcon(
                          (keys[index]),
                        ))),
                onLongPressStart: (_) async {
                  _isPressed = true;
                  do {
                    widget.sendCommand(
                        KeyboardControlMode.getKeyCode(keys[index]));
                    await Future.delayed(
                        const Duration(milliseconds: 100), () {});
                  } while (_isPressed);
                },
                onLongPressEnd: (_) => setState(() => _isPressed = false),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _getTextKeyBlocks(
                KeyboardControlMode.getPgKeys(), Colors.orange, 18)),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _getTextKeyBlocks(
                KeyboardControlMode.getRegularKeys(), Colors.red, 20)),
        Column(children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _getIconKeyBlocks(
                  KeyboardControlMode.getMediaKeys(), Colors.green, 36)),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _getIconKeyBlocks(
                  KeyboardControlMode.getVolumeKeys(), Colors.green, 36))
        ]),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _getIconKeyBlocks(
                KeyboardControlMode.getArrowKeys(), Colors.red, 36))
      ],
    );
  }
}
