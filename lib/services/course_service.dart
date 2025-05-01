import '../data/course.dart';
import '../data/timetable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// - 不包含UI相关逻辑
class CourseService {

  static List<Course> getWeekCourses(int week, List<Course> allCourses) {
    return allCourses.where((course) {
      return course.schedules.any((schedule) {
        return Course.matchesWeekPattern(week, schedule['weekPattern']);
      });
    }).toList();
  }


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
    return [
      Timetable(
        id: 'default',
        name: '默认课表',
        isDefault: true,
        courses: [],
        settings: {
          'startDate': DateTime.now().toString(),
          'totalWeeks': 20,
          'maxPeriods': 16,
          'periodTimes': {
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
          }
        }
      )
    ];
  }

  static Future<void> saveTimetables(List<Timetable> timetables) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('timetables', jsonEncode(timetables));
  }
}
