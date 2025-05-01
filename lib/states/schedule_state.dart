import 'package:flutter/material.dart';
import '../data/settings.dart';
import '../services/course_service.dart';
import '../data/course.dart';
import '../data/timetable.dart';

/// 课程表状态管理类
///
/// 负责管理课程表应用的核心状态，包括:
/// - 当前周数
/// - 当前视图类型(周/日/列表视图)
/// - 是否显示周末
/// - 当前选择的日期
/// - 所有课表数据
/// - 当前显示的课表
///
/// 功能包括:
/// - 状态持久化(通过AppSettings)
/// - 课程冲突检测
/// - 周数格式验证
/// - 课表切换管理
///
/// 继承自ChangeNotifier，用于状态变更通知
class ScheduleState extends ChangeNotifier {
  /// 当前显示的周数(1-20)
  int _currentWeek = 1;

  /// 当前视图类型('周视图'/'日视图'/'列表视图')
  String _selectedView = '周视图';

  /// 是否显示周末课程
  bool _showWeekend = true;

  /// 当前选择的日期(1-7表示星期一到星期日)
  int? _selectedDay;

  /// 所有课表列表
  List<Timetable> _timetables = [];

  /// 当前显示的课表ID
  String _currentTimetableId = '';

  /// 获取当前显示的周数
  int get currentWeek => _currentWeek;

  /// 获取当前视图类型
  String get selectedView => _selectedView;

  /// 获取是否显示周末
  bool get showWeekend => _showWeekend;

  /// 获取当前选择的日期
  int? get selectedDay => _selectedDay;

  /// 获取所有课表列表
  List<Timetable> get timetables => _timetables;

  /// 获取当前显示的课表ID
  String get currentTimetableId => _currentTimetableId;

  /// 获取当前显示的课表对象
  /// 
  /// 查找顺序:
  /// 1. 按_currentTimetableId查找
  /// 2. 查找默认课表(isDefault=true)
  /// 3. 返回第一个课表(如果存在)
  /// 4. 返回null(如果没有课表)
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

  /// 更新或添加课程
  ///
  /// 参数:
  /// - course: 要更新或添加的课程对象
  ///   - 如果course.id为空，会自动生成新ID
  ///   - 必须包含有效的周数格式
  ///
  /// 异常:
  /// - 抛出"该时间段已有其他课程"如果检测到课程冲突
  /// - 抛出"周数不能为空"如果周数格式为空
  /// - 抛出"周数格式错误"如果周数格式无效
  ///
  /// 操作流程:
  /// 1. 自动生成课程ID(如果需要)
  /// 2. 检查课程时间冲突
  /// 3. 验证周数格式
  /// 4. 更新或添加课程
  /// 5. 持久化保存
  /// 6. 通知监听器
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
