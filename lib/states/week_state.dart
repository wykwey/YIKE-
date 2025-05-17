import 'package:flutter/material.dart';
import '../services/course_service.dart';
import '../data/timetable.dart';
import '../data/course.dart';

class WeekState extends ChangeNotifier {
  int _currentWeek = 1;
  
  // 获取方法
  int get currentWeek => _currentWeek;
  
  // 初始化方法
  Future<void> loadFromTimetable(Timetable? timetable) async {
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
      notifyListeners();
    }
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
  
  // 切换周数
  void changeWeek(int week, Timetable? timetable) {
    if (timetable != null) {
      final totalWeeks = timetable.settings['totalWeeks'] ?? 20;
      if (week >= 1 && week <= totalWeeks) {
        _currentWeek = week;
        timetable.settings['currentWeek'] = week;
        CourseService.saveTimetables([timetable]); // 实际使用时需要提供完整的课表列表
        notifyListeners();
      }
    }
  }
  
  // 获取一周课程
  List<Course> getWeekCourses(int week, Timetable? timetable) {
    return timetable != null 
      ? CourseService.getWeekCourses(week, timetable.courses)
      : [];
  }
  
  // 获取某天课程
  List<Course> getDayCourses(int day, Timetable? timetable) {
    return timetable != null
      ? CourseService.getDayCourses(_currentWeek, day, timetable.courses)
      : [];
  }
} 