// In a separate file (e.g., date_provider.dart)

import 'package:flutter/material.dart';

class DateProvider extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();

  void changeSelectedDate(DateTime newDate) {
    selectedDate = newDate;
    notifyListeners(); // Notify listeners about the change
  }
}