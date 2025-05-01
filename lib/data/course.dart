/// 课程数据模型
///
/// 表示一门课程的所有相关信息，包括：
/// - 课程基本信息(名称、ID、教师、地点)
/// - 课程时间安排(周数、节次)
/// - 课程显示颜色
/// - 其他元数据
///
/// 功能包括：
/// - 周数模式匹配(matchesWeekPattern)
/// - JSON序列化/反序列化(fromJson/toJson)
/// - 空对象创建(empty)
/// - 不可变对象复制(copyWith)
class Course {
  /// 检查指定周数是否匹配课程安排模式
  ///
  /// 参数:
  /// - week: 要检查的周数(1-20)
  /// - pattern: 周数模式字符串，支持以下格式:
  ///   - 'all': 匹配所有周数
  ///   - '1,3,5': 匹配第1、3、5周
  ///   - '1-5': 匹配第1到5周
  ///   - '1-5,7,9-12': 组合匹配
  ///
  /// 返回:
  /// - bool: 如果week匹配pattern返回true，否则false
  static bool matchesWeekPattern(int week, String pattern) {
    if (pattern == 'all') return true;
    
    // 处理逗号分隔的多段范围
    final parts = pattern.split(',');
    for (final part in parts) {
      if (part.contains('-')) {
        final range = part.split('-');
        if (range.length != 2) continue;
        
        final start = int.tryParse(range[0]);
        final end = int.tryParse(range[1]);
        if (start == null || end == null) continue;
        
        if (week >= start && week <= end) {
          return true;
        }
      } else {
        final num = int.tryParse(part);
        if (num != null && week == num) {
          return true;
        }
      }
    }
    return false;
  }

  /// 创建一个空的课程对象
  ///
  /// 特性:
  /// - 所有字符串字段为空字符串
  /// - 颜色值为0(默认颜色)
  /// - 课程安排为空列表
  ///
  /// 使用场景:
  /// - 初始化新课程
  /// - 作为默认值使用
  static Course empty() {
    return Course(
      id: '',
      name: '',
      location: '',
      teacher: '',
      color: 0,
      schedules: [],
    );
  }

  /// 从JSON数据创建课程对象
  ///
  /// 参数:
  /// - json: 包含课程数据的Map，必须包含以下字段:
  ///   - id: 课程ID
  ///   - name: 课程名称
  ///   - location: 上课地点
  ///   - teacher: 授课教师
  ///   - color: 课程颜色值
  ///   - schedules: 课程时间安排列表
  ///
  /// 返回:
  /// - Course: 根据JSON数据创建的课程对象
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      teacher: json['teacher'],
      color: json['color'],
      schedules: List<Map<String, dynamic>>.from(json['schedules']),
    );
  }

  /// 课程唯一标识符
  final String id;

  /// 课程名称
  final String name;

  /// 上课地点
  final String location;

  /// 授课教师
  final String teacher;

  /// 课程显示颜色(ARGB格式)
  final int color;

  /// 课程时间安排列表
  /// 每个元素包含:
  /// - day: 星期几(1-7)
  /// - period: 节次(1-12)
  /// - weeks: 周数模式字符串(如"1-5,7,9-12")
  List<Map<String, dynamic>> schedules;

  Course({
    required this.id,
    required this.name,
    required this.location,
    required this.teacher,
    required this.color,
    required this.schedules,
  });

  /// 将课程对象转换为JSON格式
  ///
  /// 返回:
  /// - Map<String, dynamic>: 包含以下字段的JSON对象:
  ///   - id: 课程ID
  ///   - name: 课程名称
  ///   - location: 上课地点
  ///   - teacher: 授课教师
  ///   - color: 课程颜色值
  ///   - schedules: 课程时间安排列表
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'teacher': teacher,
      'color': color,
      'schedules': schedules,
    };
  }

  bool get isEmpty => id.isEmpty;

  /// 创建课程对象的副本并选择性更新字段
  ///
  /// 参数(均为可选):
  /// - id: 更新课程ID
  /// - name: 更新课程名称
  /// - location: 更新上课地点
  /// - teacher: 更新授课教师
  /// - color: 更新课程颜色
  /// - schedules: 更新课程时间安排
  ///
  /// 返回:
  /// - Course: 新创建的课程对象，未指定的字段保持原值
  Course copyWith({
    String? id,
    String? name,
    String? location,
    String? teacher,
    int? color,
    List<Map<String, dynamic>>? schedules,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      teacher: teacher ?? this.teacher,
      color: color ?? this.color,
      schedules: schedules ?? this.schedules,
    );
  }
}
