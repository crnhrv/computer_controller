import 'package:flutter/material.dart';
import '../models/keyboard_control_mode.dart';

class KeyboardControl extends StatelessWidget {
  final Function(int keyCode) sendCommand;
  const KeyboardControl({Key? key, required this.sendCommand})
      : super(key: key);

  List<Widget> _getTextKeyBlocks(List<String> keys, Color color, double textSize) {
    return List<Widget>.generate(
        keys.length,
            (index) => Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
              color: color, border: Border.all(width: 1)),
          child: TextButton(
              onPressed: () {
                sendCommand(KeyboardControlMode.getKeyCode(keys[index]));
              },
              child: Center(
                child: Text(keys[index], textAlign: TextAlign.center, style: TextStyle(fontSize: textSize)),
              )),
        ));
  }

  List<Widget> _getIconKeyBlocks(List<String> keys, Color color, double iconSize) {
    return List<Widget>.generate(
        keys.length,
        (index) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: color, border: Border.all(width: 1)),
          child: IconButton(
              onPressed: () {
                sendCommand(KeyboardControlMode.getKeyCode(keys[index]));
              },
              icon: Icon(KeyboardControlMode.getIcon(
                (keys[index]),
              ),
              size: iconSize)),
        ));
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _getTextKeyBlocks(KeyboardControlMode.getPgKeys(), Colors.orange, 18)),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _getTextKeyBlocks(KeyboardControlMode.getRegularKeys(), Colors.red, 20)),
        Column(children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _getIconKeyBlocks(KeyboardControlMode.getMediaKeys(), Colors.green, 36)),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _getIconKeyBlocks(KeyboardControlMode.getVolumeKeys(), Colors.green, 36))
        ]),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _getIconKeyBlocks(KeyboardControlMode.getArrowKeys(), Colors.red, 36))
      ],
    );
  }
}
