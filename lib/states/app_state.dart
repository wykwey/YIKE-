import 'package:flutter/material.dart';
import '../data/courses.dart';
import '../data/settings.dart';

class AppState extends ChangeNotifier {
  int _currentWeek = 1;
  String _selectedView = '周视图';
  bool _showWeekend = false;
  late List<Course> _allCourses;

  AppState() {
    _allCourses = allCourses;
  }

  // Getters
  int get currentWeek => _currentWeek;
  String get selectedView => _selectedView;
  bool get showWeekend => _showWeekend;
  List<Course> get allCourses => _allCourses;

  // 获取当前周课程
  List<Course> get weekCourses {
    return _allCourses.where((course) {
      return course.schedules.any((schedule) {
        return Course.matchesWeekPattern(_currentWeek, schedule['weekPattern']);
      });
    }).toList();
  }

  // Setters
  void setWeek(int week) {
    if (week >= 1 && week <= AppSettings.totalWeeks) {
      _currentWeek = week;
      AppSettings.saveWeekPreference(week);
      notifyListeners();
    }
  }

  void setView(String view) {
    _selectedView = view;
    AppSettings.saveViewPreference(view);
    notifyListeners();
  }

  void toggleWeekend(bool show) {
    _showWeekend = show;
    AppSettings.saveShowWeekend(show);
    notifyListeners();
  }

  void nextWeek() => setWeek(_currentWeek + 1);
  void prevWeek() => setWeek(_currentWeek - 1);
}
