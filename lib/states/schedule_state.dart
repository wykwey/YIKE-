import 'package:flutter/material.dart';
import '../services/course_service.dart';
import '../data/course.dart';
import '../data/timetable.dart';

class ScheduleState extends ChangeNotifier {
  // 状态变量
  int _currentWeek = 1;
  String _selectedView = '周视图';
  bool _showWeekend = true;
  int? _selectedDay;
  List<Timetable> _timetables = [];
  String _currentTimetableId = '';

  // 状态获取方法
  int get currentWeek => _currentWeek;
  String get selectedView => _selectedView;
  bool get showWeekend => _showWeekend;
  int? get selectedDay => _selectedDay;
  List<Timetable> get timetables => _timetables;
  String get currentTimetableId => _currentTimetableId;

  // 当前课表获取方法
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
    _initState();
  }

  // 初始化状态
  Future<void> _initState() async {
    await _initTimetables();
    await _loadSettings();
  }

  Future<void> _initTimetables() async {
    _timetables = await CourseService.loadTimetables();
    if (_timetables.isEmpty) {
      _timetables = [Timetable(id: 'default', name: '示例课表', isDefault: true, courses: [])];
    }
    
    // 尝试加载保存的当前课表ID
    final savedId = _timetables.firstWhere(
      (t) => t.settings['isCurrent'] == true,
      orElse: () => _timetables.firstWhere(
        (t) => t.isDefault,
        orElse: () => _timetables.first
      )
    ).id;
    
    _currentTimetableId = savedId;
    notifyListeners();
  }

  // 保存当前课表设置
  Future<void> _saveCurrentSettings() async {
    final timetable = currentTimetable;
    if (timetable != null) {
      timetable.settings['currentWeek'] = _currentWeek;
      timetable.settings['selectedView'] = _selectedView;
      timetable.settings['showWeekend'] = _showWeekend;
      timetable.settings['totalWeeks'] = timetable.settings['totalWeeks'] ?? 20;
      timetable.settings['maxPeriods'] = timetable.settings['maxPeriods'] ?? 16;
      await CourseService.saveTimetables(_timetables);
    }
  }

  // 加载设置
  Future<void> _loadSettings() async {
    final timetable = currentTimetable;
    if (timetable != null) {
      // 加载日期设置
      DateTime? startDate;
      if (timetable.settings['startDate'] != null) {
        try {
          startDate = DateTime.parse(timetable.settings['startDate'].toString());
        } catch (e) {
          startDate = null;
        }
      }

      // 计算当前周数
      _currentWeek = _calculateCurrentWeek(timetable, startDate);
      
      // 加载视图偏好
      _selectedView = timetable.settings['selectedView']?.toString() ?? '周视图';
      
      // 加载周末显示设置
      _showWeekend = timetable.settings['showWeekend'] is bool 
          ? timetable.settings['showWeekend'] as bool
          : timetable.settings['showWeekend']?.toString() == 'true';

      await _saveCurrentSettings();
    } else if (_timetables.isNotEmpty) {
      // 处理默认课表
      final defaultTimetable = _timetables.firstWhere((t) => t.isDefault, orElse: () => _timetables.first);
      
      _currentWeek = defaultTimetable.settings['currentWeek'] as int? ?? 1;
      _selectedView = defaultTimetable.settings['selectedView'] as String? ?? '周视图';
      _showWeekend = defaultTimetable.settings['showWeekend'] as bool? ?? false;
      
      await _saveCurrentSettings();
    } else {
      // 无课表时的默认值
      _currentWeek = 1;
      _selectedView = '周视图';
      _showWeekend = false;
    }
    notifyListeners();
  }

  // 计算当前周数
  int _calculateCurrentWeek(Timetable timetable, DateTime? startDate) {
    if (startDate != null) {
      final now = DateTime.now();
      final diff = now.difference(startDate).inDays;
      int week = (diff ~/ 7) + 1;
      if (week < 1) week = 1;
      final totalWeeks = timetable.settings['totalWeeks'] ?? 20;
      if (week > totalWeeks) week = totalWeeks;
      return week;
    }
    return int.tryParse(timetable.settings['currentWeek']?.toString() ?? '1') ?? 1;
  }

  Future<void> updateTotalWeeks(int weeks) async {
    final timetable = currentTimetable;
    if (timetable != null) {
      timetable.settings['totalWeeks'] = weeks;
      await CourseService.saveTimetables(_timetables);
      notifyListeners();
    }
  }

  Future<void> updateMaxPeriods(int periods) async {
    final timetable = currentTimetable;
    if (timetable != null) {
      timetable.settings['maxPeriods'] = periods;
      await CourseService.saveTimetables(_timetables);
      notifyListeners();
    }
  }

  Future<void> updateTimetable(Timetable timetable) async {
    final index = _timetables.indexWhere((t) => t.id == timetable.id);
    if (index >= 0) {
      _timetables[index] = timetable;
      await CourseService.saveTimetables(_timetables);
      notifyListeners();
    }
  }

  Future<void> updateCourse(Course course) async {
    final timetable = currentTimetable;
    if (timetable != null) {
      if (course.id.isEmpty) {
        course = course.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
      }
      
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

      if (hasConflict) throw Exception('该时间段已有其他课程');

      for (var schedule in course.schedules) {
        final weekPattern = schedule['weekPattern'] as String? ?? '';
        if (weekPattern.isEmpty) throw Exception('周数不能为空');
        if (!RegExp(r'^(\d+(-\d+)?)(,\d+(-\d+)?)*$').hasMatch(weekPattern)) {
          throw Exception('周数格式错误，请使用如"1-16"、"1,3,5"或"1-3,5,7-9"的格式');
        }
      }

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
    final timetable = currentTimetable;
    if (timetable != null) {
      final totalWeeks = timetable.settings['totalWeeks'] ?? 20;
      if (week >= 1 && week <= totalWeeks) {
        _currentWeek = week;
        timetable.settings['currentWeek'] = week;
        CourseService.saveTimetables(_timetables);
        notifyListeners();
      }
    }
  }

  int get totalWeeks => currentTimetable?.settings['totalWeeks'] ?? 20;
  int get maxPeriods => currentTimetable?.settings['maxPeriods'] ?? 16;

  void changeView(String view) {
    if (_selectedView != view) {
      _selectedView = view;
      final timetable = currentTimetable;
      if (timetable != null) {
        timetable.settings['selectedView'] = view;
        CourseService.saveTimetables(_timetables);
      }
      notifyListeners();
    }
  }

  void toggleWeekend(bool show) {
    _showWeekend = show;
    final timetable = currentTimetable;
    if (timetable != null) {
      timetable.settings['showWeekend'] = show;
      CourseService.saveTimetables(_timetables);
      notifyListeners();
    }
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
      // 清除所有课表的isCurrent标记
      for (var t in _timetables) {
        t.settings.remove('isCurrent');
      }
      
      // 设置新课表为当前
      _timetables.firstWhere((t) => t.id == id).settings['isCurrent'] = true;
      
      // 切换到新课表
      _currentTimetableId = id;
      
      // 保存所有课表
      await CourseService.saveTimetables(_timetables);
      
      // 加载新课表设置
      await _loadSettings();
      
      // 通知监听器
      notifyListeners();
    }
  }
}
