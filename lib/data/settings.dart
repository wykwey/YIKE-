
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppSettings {
  static late String selectedView;
  static late int currentWeek;
  static late DateTime startDate;
  static late int totalWeeks;
  static late bool showWeekend;
  static late int maxPeriods;
  static late Map<String, String> periodTimes;

  static const Map<String, String> _defaultPeriodTimes = {
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

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    selectedView = prefs.getString('selectedView') ?? '周视图';
    currentWeek = prefs.getInt('currentWeek') ?? 1;
    startDate = DateTime.parse(prefs.getString('startDate') ?? DateTime.now().toString());
    totalWeeks = prefs.getInt('totalWeeks') ?? 20;
    showWeekend = prefs.getBool('showWeekend') ?? true;
    maxPeriods = prefs.getInt('maxPeriods') ?? 16;
    try {
      final periodTimesJson = prefs.getString('periodTimes');
      if (periodTimesJson != null) {
        final decoded = jsonDecode(periodTimesJson);
        if (decoded is Map) {
          periodTimes = Map<String, String>.from(decoded);
        } else {
          periodTimes = Map<String, String>.from(_defaultPeriodTimes);
        }
      } else {
        periodTimes = Map<String, String>.from(_defaultPeriodTimes);
      }
    } catch (e) {
      periodTimes = Map<String, String>.from(_defaultPeriodTimes);
    }
  }

  static Future<void> saveViewPreference(String view) async {
    selectedView = view;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedView', view);
  }

  static Future<void> saveWeekPreference(int week) async {
    currentWeek = week;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentWeek', week);
  }

  static Future<void> saveStartDate(DateTime date) async {
    startDate = date;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('startDate', date.toString());
  }

  static Future<void> saveTotalWeeks(int weeks) async {
    totalWeeks = weeks;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalWeeks', weeks);
  }

  static Future<void> saveShowWeekend(bool show) async {
    showWeekend = show;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWeekend', show);
  }

  static Future<void> saveWeekendPreference(bool show) async {
    showWeekend = show;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWeekend', show);
  }

  static Future<void> saveMaxPeriods(int periods) async {
    maxPeriods = periods;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('maxPeriods', periods);
  }

  static Future<void> savePeriodTimes(Map<String, String> times) async {
    periodTimes = times;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('periodTimes', jsonEncode(times));
  }
}
