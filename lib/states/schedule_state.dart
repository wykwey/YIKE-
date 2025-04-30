import 'package:flutter/material.dart';
import '../data/settings.dart';
import '../services/course_service.dart';
import '../data/courses.dart';

class ScheduleState extends ChangeNotifier {
  int _currentWeek = 1;
  String _selectedView = '周视图';
  bool _showWeekend = true;
  int? _selectedDay;

  int get currentWeek => _currentWeek;
  String get selectedView => _selectedView;
  bool get showWeekend => _showWeekend;
  int? get selectedDay => _selectedDay;

  ScheduleState() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await AppSettings.init();
    _currentWeek = AppSettings.currentWeek;
    _selectedView = AppSettings.selectedView;
    _showWeekend = AppSettings.showWeekend;
    notifyListeners();
  }

  void changeWeek(int week) {
    if (week >= 1 && week <= AppSettings.totalWeeks) {
      _currentWeek = week;
      AppSettings.saveWeekPreference(week);
      notifyListeners();
    }
  }

  void changeView(String view) {
    if (_selectedView != view) {
      _selectedView = view;
      AppSettings.saveViewPreference(view);
      notifyListeners();
    }
  }

  void toggleWeekend(bool show) {
    _showWeekend = show;
    AppSettings.saveWeekendPreference(show);
    notifyListeners();
  }

  void selectDay(int day) {
    _selectedDay = day;
    notifyListeners();
  }

  List<Course> getWeekCourses(int week) {
    return CourseService.getWeekCourses(week, allCourses);
  }

  List<Course> getDayCourses(int day) {
    return CourseService.getDayCourses(_currentWeek, day, allCourses);
  }
}
