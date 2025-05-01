import 'package:flutter/material.dart';
import '../components/time_settings_dialog.dart';

class AppSettings {
  static const Map<String, String> defaultPeriodTimes = {
    '1': '08:00-08:45',
    '2': '08:50-09:35',
    '3': '09:40-10:25',
    '4': '10:30-11:15',
    '5': '11:20-12:05',
    '6': '13:30-14:15',
    '7': '14:20-15:05',
    '8': '15:10-15:55',
    '9': '16:00-16:45',
    '10': '16:50-17:35',
    '11': '18:30-19:15',
    '12': '19:20-20:05',
    '13': '20:10-20:55',
    '14': '21:00-21:45',
    '15': '21:50-22:35',
    '16': '22:40-23:25'
  };

  static Future<void> showTimeSettingsDialog(
    BuildContext context, 
    Map<String, String> periodTimes,
    int maxPeriods,
    Function(Map<String, String>) onSave
  ) async {
    final controllers = Map.fromEntries(
      periodTimes.entries
        .where((e) => int.parse(e.key) <= maxPeriods)
        .map((e) => MapEntry(e.key, TextEditingController(text: e.value)))
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TimeSettingsDialog(controllers: controllers),
    );

    if (result == true) {
      final newTimes = Map.fromEntries(
        controllers.entries.map((e) => MapEntry(e.key, e.value.text)),
      );
      onSave(newTimes);
    }
  }
}
