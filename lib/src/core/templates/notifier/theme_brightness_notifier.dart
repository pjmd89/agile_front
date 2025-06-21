String themeBrightnessNotifier = r'''import 'package:flutter/material.dart';

class ThemeBrightnessNotifier  extends ChangeNotifier{
  Brightness _brightness = Brightness.dark;

  Brightness get brightness => _brightness;

  set brightnessMode(BrightnessMode value) {
    switch (value) {
      case BrightnessMode.light:
        _brightness = Brightness.light;
        break;
      case BrightnessMode.dark:
        _brightness = Brightness.dark;
        break;
    }
    notifyListeners();
  }
}

enum BrightnessMode{
  light,
  dark,
}''';