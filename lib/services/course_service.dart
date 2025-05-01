import '../data/course.dart';
import '../data/timetable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 课程服务类
///
/// 提供课程相关的核心业务逻辑处理，包括:
/// - 课程数据查询(按周/天/节次)
/// - 课程数据持久化(保存/加载)
/// - 课表管理(保存/加载)
///
/// 特性:
/// - 所有方法均为静态方法
/// - 使用SharedPreferences进行本地存储
/// - 与ScheduleState配合使用
///
/// 注意:
/// - 不包含状态管理逻辑
/// - 不包含UI相关逻辑
class CourseService {
  /// 获取指定周数的课程列表
  ///
  /// 参数:
  /// - week: 要查询的周数(1-20)
  /// - allCourses: 所有课程列表
  ///
  /// 返回:
  /// - List<Course>: 包含指定周数所有课程的列表
  ///
  /// 筛选逻辑:
  /// - 使用Course.matchesWeekPattern检查每个课程的周数安排
  /// - 只要课程在指定周数有任一时间段安排即包含在结果中
  static List<Course> getWeekCourses(int week, List<Course> allCourses) {
    return allCourses.where((course) {
      return course.schedules.any((schedule) {
        return Course.matchesWeekPattern(week, schedule['weekPattern']);
      });
    }).toList();
  }

  /// 获取指定周数和星期的课程
  ///
  /// 参数:
  /// - week: 要查询的周数(1-20)
  /// - day: 要查询的星期(1-7表示星期一到星期日)
  /// - allCourses: 所有课程列表
  ///
  /// 返回:
  /// - List<Course>: 包含指定周数和星期所有课程的列表
  ///
  /// 筛选逻辑:
  /// - 同时匹配星期和周数安排
  /// - 使用Course.matchesWeekPattern检查周数安排
  static List<Course> getDayCourses(int week, int day, List<Course> allCourses) {
    return allCourses.where((course) {
      return course.schedules.any((s) => 
        s['day'] == day && 
        Course.matchesWeekPattern(week, s['weekPattern'])
      );
    }).toList();
  }

  /// 获取指定周数、星期和节次的课程
  static Course getPeriodCourse(int week, int day, int period, List<Course> allCourses) {
    return allCourses.firstWhere(
      (c) => c.schedules.any((s) => 
        s['day'] == day && 
        s['periods'].contains(period) &&
        Course.matchesWeekPattern(week, s['weekPattern'])),
      orElse: () => Course.empty(),
    );
  }

  /// 更新课程信息
  static Future<void> updateCourse(Course updatedCourse, List<Course> allCourses) async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = prefs.getString('courses');
    List<Course> existingCourses = coursesJson != null 
      ? (jsonDecode(coursesJson) as List).map((e) => Course.fromJson(e)).toList()
      : allCourses;
    
    // 替换或添加更新后的课程
    existingCourses.removeWhere((c) => c.id == updatedCourse.id);
    existingCourses.add(updatedCourse);
    
    await prefs.setString('courses', jsonEncode(existingCourses.map((c) => c.toJson()).toList()));
  }

  static Future<List<Course>> loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = prefs.getString('courses');
    if (coursesJson != null) {
      final decoded = jsonDecode(coursesJson) as List;
      return decoded.map((e) => Course.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<Timetable>> loadTimetables() async {
    final prefs = await SharedPreferences.getInstance();
    final timetablesJson = prefs.getString('timetables');
    if (timetablesJson != null) {
      final decoded = jsonDecode(timetablesJson) as List;
      return decoded.map((e) => Timetable.fromJson(e)).toList();
    }
    return [];
  }

  static Future<void> saveTimetables(List<Timetable> timetables) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('timetables', jsonEncode(timetables));
  }
}
