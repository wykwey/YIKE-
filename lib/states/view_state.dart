import 'package:flutter/material.dart';
import '../services/course_service.dart';
import '../data/timetable.dart';

class ViewState extends ChangeNotifier {
  String _selectedView = '周视图';
  bool _showWeekend = true;
  int? _selectedDay;
  
  // 获取方法
  String get selectedView => _selectedView;
  bool get showWeekend => _showWeekend;
  int? get selectedDay => _selectedDay;
  
  // 初始化方法（从课表设置加载）
  Future<void> loadFromTimetable(Timetable? timetable) async {
    if (timetable != null) {
      _selectedView = timetable.settings['selectedView']?.toString() ?? '周视图';
      _showWeekend = timetable.settings['showWeekend'] is bool 
          ? timetable.settings['showWeekend'] as bool
          : timetable.settings['showWeekend']?.toString() == 'true';
      notifyListeners();
    }
  }
  
  // 更改视图
  void changeView(String view, Timetable? timetable) {
    if (_selectedView != view) {
      _selectedView = view;
      if (timetable != null) {
        timetable.settings['selectedView'] = view;
        CourseService.saveTimetables([timetable]); // 实际使用时需要提供完整的课表列表
      }
      notifyListeners();
    }
  }
  
  // 切换周末显示
  void toggleWeekend(bool show, Timetable? timetable) {
    if (_showWeekend != show) {
      _showWeekend = show;
      if (timetable != null) {
        timetable.settings['showWeekend'] = show;
        CourseService.saveTimetables([timetable]); // 实际使用时需要提供完整的课表列表
      }
      notifyListeners();
    }
  }
  
  // 选择日期
  void selectDay(int? day) {
    _selectedDay = day;
    notifyListeners();
  }
} 