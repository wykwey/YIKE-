import './course.dart';
import '../constants/app_constants.dart';

class Timetable {
  final String id;
  final String name;
  final List<Course> courses;
  final bool isDefault;
  final Map<String, dynamic> settings;

  Timetable({
    required this.id,
    required this.name,
    required this.courses,
    this.isDefault = false,
    Map<String, dynamic>? settings,
  }) : settings = settings ?? {
      'startDate': DateTime.now().toString(),
      'totalWeeks': 20,
      'maxPeriods': 16,
      'periodTimes': AppConstants.defaultPeriodTimes
    };

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      id: json['id'],
      name: json['name'],
      courses: (json['courses'] as List).map((e) => Course.fromJson(e)).toList(),
      isDefault: json['isDefault'] ?? false,
      settings: json['settings'] != null 
        ? Map<String, dynamic>.from(json['settings'])
        : null,
    );
  }

  static Timetable fromRawData(
    List<Map<String, dynamic>> rawCourses,
    {Map<String, dynamic>? settings}
  ) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final courses = rawCourses.map((course) {
      // 转换周次数组为字符串格式
      final weeks = course['weeks'] as List;
      String weekPattern;
      if (weeks.length == 1) {
        weekPattern = weeks.first.toString();
      } else {
        weekPattern = '${weeks.first}-${weeks.last}';
      }

      return Course(
        id: '${course['name']}-${course['position']}-$weekPattern-$timestamp',
        name: course['name'],
        location: course['position'],
        teacher: course['teacher'],
        color: 0, // 默认颜色
        schedules: [{
          'day': course['day'],
          'periods': course['sections'],
          'weekPattern': weekPattern
        }]
      );
    }).toList();

    return Timetable(
      id: 'timetable-$timestamp',
      name: '课表-$timestamp',
      courses: courses,
      settings: settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'courses': courses.map((e) => e.toJson()).toList(),
      'isDefault': isDefault,
      'settings': settings,
    };
  }

  Timetable copyWith({
    String? id,
    String? name,
    List<Course>? courses, 
    bool? isDefault,
    Map<String, dynamic>? settings,
  }) {
    return Timetable(
      id: id ?? this.id,
      name: name ?? this.name,
      courses: courses ?? this.courses,
      isDefault: isDefault ?? this.isDefault,
      settings: settings ?? this.settings,
    );
  }
}
