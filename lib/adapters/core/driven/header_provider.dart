import 'package:flutter/material.dart';

class HeaderProvider with ChangeNotifier {
  String _title = '';
  bool _showBack = false;
  bool _showChips = true;

  String get title => _title;
  bool get showBack => _showBack;
  bool get showChips => _showChips;

  void set({String? title, bool? showBack, bool? showChips}) {
    if (title != null) _title = title;
    if (showBack != null) _showBack = showBack;
    if (showChips != null) _showChips = showChips;
    notifyListeners();
  }

  void reset() {
    _title = '';
    _showBack = false;
    _showChips = true;
    notifyListeners();
  }
}
