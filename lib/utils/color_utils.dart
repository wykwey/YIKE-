import 'package:flutter/material.dart';

class ColorUtils {
  static const Map<String, Color> courseColorMap = {
    'orange': Colors.orange,
    'green': Colors.green,
    'blue': Colors.blue,
    'purple': Colors.purple,
    'red': Colors.red,
    'teal': Colors.teal,
    'amber': Colors.amber,
    'cyan': Colors.cyan,
    'indigo': Colors.indigo,
    'pink': Colors.pink,
    'lime': Colors.lime,
    'deepOrange': Colors.deepOrange,
  };

  static final List<Color> courseColors = courseColorMap.values.toList();

  static Color getCourseColor(String name) {
    return courseColors[name.hashCode % courseColors.length];
  }

  static Color getWeekColor(String weekPattern) {
    if (weekPattern == 'all') return Colors.white;
    final week = int.tryParse(weekPattern.split(',').first) ?? 1;
    return week % 2 == 0 ? Colors.grey[100]! : Colors.white;
  }
}
