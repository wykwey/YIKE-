
import '../utils/color_utils.dart';

class Course {

  static bool matchesWeekPattern(int week, String pattern) {
    if (pattern == 'all') return true;
    
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

  static List<int> parsePeriods(String input) {
    final periods = <int>[];
    for (final part in input.split(',')) {
      if (part.contains('-')) {
        final range = part.split('-');
        if (range.length == 2) {
          final start = int.tryParse(range[0]);
          final end = int.tryParse(range[1]);
          if (start != null && end != null) {
            for (int i = start; i <= end; i++) {
              periods.add(i);
            }
          }
        }
      } else {
        final num = int.tryParse(part);
        if (num != null) periods.add(num);
      }
    }
    return periods..sort();
  }


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


  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      teacher: json['teacher'],
      color: (json['color'] is String && ColorUtils.courseColorMap.containsKey(json['color']))
          ? ColorUtils.courseColorMap[json['color']]!.value
          : (json['color'] is int ? json['color'] : 0),
      schedules: (json['schedules'] as List).map((schedule) {
        final map = Map<String, dynamic>.from(schedule);
        if (map['periods'] != null) {
          map['periods'] = (map['periods'] as List).map((e) => e as int).toList();
        }
        return map;
      }).toList(),
    );
  }

  final String id;

  final String name;


  final String location;


  final String teacher;


  int color;

  List<Map<String, dynamic>> schedules;

  Course({
    required this.id,
    required this.name,
    required this.location,
    required this.teacher,
    required this.color,
    required this.schedules,
  });


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
