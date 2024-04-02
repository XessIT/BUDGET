import 'package:flutter/material.dart';

class RemainingAmountProvider extends ChangeNotifier {
  String _remaining = '';

  String get remaining => _remaining;

  void updateRemaining(String remaining) {
    _remaining = remaining;
    notifyListeners();
  }
}
