import 'package:flutter/foundation.dart';

enum AppSection {
  home,
  planner,
  focus,
  alarm,
  settings,
}

class NavigationProvider extends ChangeNotifier {
  AppSection _currentSection = AppSection.home;

  AppSection get currentSection => _currentSection;
  int get currentIndex => AppSection.values.indexOf(_currentSection);

  void setSection(AppSection section) {
    if (_currentSection == section) {
      return;
    }

    _currentSection = section;
    notifyListeners();
  }

  void setIndex(int index) {
    if (index < 0 || index >= AppSection.values.length) {
      return;
    }

    setSection(AppSection.values[index]);
  }
}
