import 'package:flutter/material.dart';
import '../services/course_service.dart';
import '../data/timetable.dart';
import '../data/course.dart';

class TimetableState extends ChangeNotifier {
  List<Timetable> _timetables = [];
  String _currentTimetableId = '';
  bool _isLoading = false;
  
  // 获取方法
  List<Timetable> get timetables => _timetables;
  String get currentTimetableId => _currentTimetableId;
  bool get isLoading => _isLoading;
  
  // 获取当前课表
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
  
  // 其他属性获取
  int get totalWeeks => currentTimetable?.settings['totalWeeks'] ?? 20;
  int get maxPeriods => currentTimetable?.settings['maxPeriods'] ?? 16;
  
  // 构造函数
  TimetableState() {
    _initTimetables();
  }
  
  // 初始化课表
  Future<void> _initTimetables() async {
    _isLoading = true;
    notifyListeners();
    
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
    _isLoading = false;
    notifyListeners();
  }
  
  // 添加课表
  Future<void> addTimetable(Timetable timetable) async {
    _timetables.add(timetable);
    await CourseService.saveTimetables(_timetables);
    notifyListeners();
  }
  
  // 删除课表
  Future<void> removeTimetable(String id) async {
    _timetables.removeWhere((t) => t.id == id);
    if (_currentTimetableId == id && _timetables.isNotEmpty) {
      _currentTimetableId = _timetables.first.id;
    }
    await CourseService.saveTimetables(_timetables);
    notifyListeners();
  }
  
  // 切换课表
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
      
      // 通知监听器
      notifyListeners();
    }
  }
  
  // 更新课表
  Future<void> updateTimetable(Timetable timetable) async {
    final index = _timetables.indexWhere((t) => t.id == timetable.id);
    if (index >= 0) {
      _timetables[index] = timetable;
      await CourseService.saveTimetables(_timetables);
      notifyListeners();
    }
  }
  
  // 更新课程
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
  
  // 更新总周数
  Future<void> updateTotalWeeks(int weeks) async {
    final timetable = currentTimetable;
    if (timetable != null) {
      timetable.settings['totalWeeks'] = weeks;
      await CourseService.saveTimetables(_timetables);
      notifyListeners();
    }
  }

  // 更新最大节次
  Future<void> updateMaxPeriods(int periods) async {
    final timetable = currentTimetable;
    if (timetable != null) {
      timetable.settings['maxPeriods'] = periods;
      await CourseService.saveTimetables(_timetables);
      notifyListeners();
    }
  }
} 