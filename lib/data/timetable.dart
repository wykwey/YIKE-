import './course.dart';

/// 课表数据模型
///
/// 表示一个完整的课表，包含:
/// - 课表元数据(id, name, isDefault)
/// - 课程列表(courses)
///
/// 功能包括:
/// - JSON序列化/反序列化(fromJson/toJson)
/// - 不可变对象复制(copyWith)
///
/// 使用场景:
/// - 存储和管理用户创建的多个课表
/// - 作为当前显示的课表数据容器
class Timetable {
  /// 课表唯一标识符
  final String id;

  /// 课表名称(如"2023秋季学期")
  final String name;

  /// 课程列表
  /// 包含该课表的所有课程对象
  final List<Course> courses;

  /// 是否为默认课表
  /// true表示这是用户默认显示的课表
  final bool isDefault;

  Timetable({
    required this.id,
    required this.name,
    required this.courses,
    this.isDefault = false,
  });

  /// 从JSON数据创建课表对象
  ///
  /// 参数:
  /// - json: 包含课表数据的Map，必须包含以下字段:
  ///   - id: 课表ID
  ///   - name: 课表名称
  ///   - courses: 课程列表(JSON数组)
  ///   - isDefault: 是否为默认课表(可选，默认为false)
  ///
  /// 返回:
  /// - Timetable: 根据JSON数据创建的课表对象
  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      id: json['id'],
      name: json['name'],
      courses: (json['courses'] as List).map((e) => Course.fromJson(e)).toList(),
      isDefault: json['isDefault'] ?? false,
    );
  }

  /// 将课表对象转换为JSON格式
  ///
  /// 返回:
  /// - Map<String, dynamic>: 包含以下字段的JSON对象:
  ///   - id: 课表ID
  ///   - name: 课表名称
  ///   - courses: 课程列表(转换为JSON数组)
  ///   - isDefault: 是否为默认课表
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'courses': courses.map((e) => e.toJson()).toList(),
      'isDefault': isDefault,
    };
  }

  /// 创建课表对象的副本并选择性更新字段
  ///
  /// 参数(均为可选):
  /// - id: 更新课表ID
  /// - name: 更新课表名称
  /// - courses: 更新课程列表
  /// - isDefault: 更新是否为默认课表
  ///
  /// 返回:
  /// - Timetable: 新创建的课表对象，未指定的字段保持原值
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
