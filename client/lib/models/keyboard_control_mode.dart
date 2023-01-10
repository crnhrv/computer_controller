
import 'package:flutter/material.dart';

class KeyboardControlMode {
  KeyboardControlMode();

  static const Map<String, int> keyCodes =
  { "PAGE UP" : 0x21,
    "PAGE DOWN" : 0x22,
    "←" : 0x25,
    "↑" : 0x26,
    "→" : 0x27,
    "↓" : 0x28,
    "F" : 0x46,
    "V" : 0x56,
    "SPACE": 0x20,
    "SKIP_NEXT": 0xB0,
    "SKIP_BACK": 0xB1,
    "PLAY_PAUSE": 0xB3,
    "VOLUME_UP": 0xAF,
    "VOLUME_DOWN": 0xAE,
    "VOLUME_MUTE": 0xAD,
  };

  static const Map<String, IconData> iconMap =
  { "←" : Icons.arrow_back,
    "↑" : Icons.arrow_upward,
    "→" : Icons.arrow_forward,
    "↓" : Icons.arrow_downward,
    "SKIP_BACK": Icons.skip_previous,
    "SKIP_NEXT": Icons.skip_next,
    "PLAY_PAUSE": Icons.not_started_outlined,
    "VOLUME_UP": Icons.volume_up,
    "VOLUME_DOWN": Icons.volume_down,
    "VOLUME_MUTE": Icons.volume_mute
  };

  static List<String> getKeys() {
    return KeyboardControlMode.keyCodes.keys.toList();
  }

  static List<String> getMediaKeys() {
    return ["SKIP_BACK", "PLAY_PAUSE", "SKIP_NEXT"];
  }

  static List<String> getVolumeKeys() {
    return KeyboardControlMode.keyCodes.keys.where((element) => element.contains("VOLUME")).toList();
  }

  static List<String> getArrowKeys() {
    return ["←","↑","↓","→"];
  }

  static List<String> getRegularKeys() {
    return ["F","SPACE","V"];
  }

  static List<String> getPgKeys() {
    return KeyboardControlMode.keyCodes.keys.where((element) => element.contains("PAGE")).toList();
  }



  static int getKeyCode(String key) {
    if (KeyboardControlMode.keyCodes.containsKey(key)) {
      return (KeyboardControlMode.keyCodes[key]!);
    }

    return -1;
  }

  static IconData? getIcon(String key) {
    return KeyboardControlMode.iconMap[key];
  }
}

