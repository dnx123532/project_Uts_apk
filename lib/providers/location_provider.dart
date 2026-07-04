import 'package:flutter/material.dart';

class LocationState extends ChangeNotifier {
  String _selectedCity = 'Medan'; // Default awal
  String get selectedCity => _selectedCity;

  void setCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }
}
