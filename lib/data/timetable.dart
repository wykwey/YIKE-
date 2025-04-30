import './course.dart';

/// 课表数据模型
///
/// 包含:
/// - 课表ID和名称
/// - 课程列表
/// - 是否为默认课表
class Timetable {
  final String id;
  final String name;
  final List<Course> courses;
  final bool isDefault;

  Timetable({
    required this.id,
    required this.name,
    required this.courses,
    this.isDefault = false,
  });

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      id: json['id'],
      name: json['name'],
      courses: (json['courses'] as List).map((e) => Course.fromJson(e)).toList(),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'courses': courses.map((e) => e.toJson()).toList(),
      'isDefault': isDefault,
    };
  }

  Timetable copyWith({
    String? id,
    String? name,
    List<Course>? courses,
    bool? isDefault,
  }) {
    return Timetable(
      id: id ?? this.id,
      name: name ?? this.name,
      courses: courses ?? this.courses,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
