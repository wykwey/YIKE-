import 'package:flutter/material.dart';
import '../data/settings.dart';
import '../services/course_service.dart';
import '../data/course.dart';
import '../data/timetable.dart';

class ScheduleState extends ChangeNotifier {
  int _currentWeek = 1;
  String _selectedView = '周视图';
  bool _showWeekend = true;
  int? _selectedDay;
  List<Timetable> _timetables = [];
  String _currentTimetableId = '';

  int get currentWeek => _currentWeek;
  String get selectedView => _selectedView;
  bool get showWeekend => _showWeekend;
  int? get selectedDay => _selectedDay;
  List<Timetable> get timetables => _timetables;
  String get currentTimetableId => _currentTimetableId;

  Timetable? get currentTimetable {
    try {
      return _timetables.firstWhere((t) => t.id == _currentTimetableId);
    } catch (e) {
      try {
        return _timetables.firstWhere((t) => t.isDefault);
      } catch (e) {
        return _timetables.isNotEmpty ? _timetables.first : null;
      }
    }
  }

  ScheduleState() {
    _loadSettings();
    _initTimetables();
  }

  Future<void> _initTimetables() async {
    _timetables = await CourseService.loadTimetables();
    if (_timetables.isEmpty) {
      _timetables = [
        Timetable(
          id: 'default',
          name: '示例课表',
          isDefault: true,
          courses: []
        )
      ];
    }
    _currentTimetableId = _timetables.first.id;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    await AppSettings.init();
    _currentWeek = AppSettings.currentWeek;
    _selectedView = AppSettings.selectedView;
    _showWeekend = AppSettings.showWeekend;
    notifyListeners();
  }

  Future<void> updateCourse(Course course) async {
    final timetable = currentTimetable;
    if (timetable != null) {
      // 确保新课程有唯一ID
      if (course.id.isEmpty) {
        course = course.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
      }
      
      // 检查是否已有相同时间段的课程
      final hasConflict = timetable.courses.any((c) {
        if (c.id == course.id) return false;
        return c.schedules.any((s1) {
          return course.schedules.any((s2) {
            if (s1['day'] != s2['day']) return false;
            final periods1 = (s1['periods'] as List).cast<int>();
            final periods2 = (s2['periods'] as List).cast<int>();
            return periods1.any((p1) => periods2.contains(p1));
          });
        });
      });

      if (hasConflict) {
        throw Exception('该时间段已有其他课程');
      }

      // 验证周数格式
      for (var schedule in course.schedules) {
        final weekPattern = schedule['weekPattern'] as String? ?? '';
        if (weekPattern.isEmpty) {
          throw Exception('周数不能为空');
        }
        
        // 检查是否为连续周数格式(1-16)、离散周数格式(1,3,5)或混合格式(1-3,5,7-9)
        if (!RegExp(r'^(\d+(-\d+)?)(,\d+(-\d+)?)*$').hasMatch(weekPattern)) {
          throw Exception('周数格式错误，请使用如"1-16"、"1,3,5"或"1-3,5,7-9"的格式');
        }
      }

      // 更新或添加课程
      final index = timetable.courses.indexWhere((c) => c.id == course.id);
      if (index >= 0) {
        timetable.courses[index] = course;
      } else {
        timetable.courses.add(course);
      }
      
      await CourseService.saveTimetables(_timetables);
      notifyListeners();
    }
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
    return currentTimetable != null 
      ? CourseService.getWeekCourses(week, currentTimetable!.courses)
      : [];
  }

  List<Course> getDayCourses(int day) {
    return currentTimetable != null
      ? CourseService.getDayCourses(_currentWeek, day, currentTimetable!.courses)
      : [];
  }

  Future<void> addTimetable(Timetable timetable) async {
    _timetables.add(timetable);
    await CourseService.saveTimetables(_timetables);
    notifyListeners();
  }

  Future<void> removeTimetable(String id) async {
    _timetables.removeWhere((t) => t.id == id);
    if (_currentTimetableId == id && _timetables.isNotEmpty) {
      _currentTimetableId = _timetables.first.id;
    }
    await CourseService.saveTimetables(_timetables);
    notifyListeners();
  }

  Future<void> switchTimetable(String id) async {
    if (_timetables.any((t) => t.id == id)) {
      _currentTimetableId = id;
      await CourseService.saveTimetables(_timetables);
      notifyListeners();
    }
  }
}
