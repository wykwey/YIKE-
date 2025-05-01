import './course.dart';
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
