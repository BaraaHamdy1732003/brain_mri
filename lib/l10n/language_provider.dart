import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); 

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isRussian => _locale.languageCode == 'ru';

  void setEnglish() {
    _locale = const Locale('en');
    notifyListeners();
  }

  void setArabic() {
    _locale = const Locale('ar');
    notifyListeners();
  }

  void setRussian() {
    _locale = const Locale('ru');
    notifyListeners();
  }

  void changeLanguage(String languageCode) {
    _locale = Locale(languageCode);
    notifyListeners();
  }

  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }
    notifyListeners();
  }
}