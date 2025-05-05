import 'package:flutter/material.dart';

class ColorUtils {
  static const Map<String, Color> courseColorMap = {

  'blue': Color(0xFFBBDEFB),       // 柔和蓝
  'green': Color(0xFFC8E6C9),      // 柔和绿
  'amber': Color(0xFFFFF9C4),      // 柔和黄
  'indigo': Color(0xFFC5CAE9),     // 柔和靛
  'pink': Color(0xFFF8BBD0),       // 柔和粉
  'cyan': Color(0xFFB2EBF2),       // 柔和青
  'deepOrange': Color(0xFFFFCCBC), // 柔和橙
  'purple': Color(0xFFE1BEE7),     // 柔和紫
  'lime': Color(0xFFF0F4C3),       // 柔和柠檬
  'teal': Color(0xFFB2DFDB),       // 柔和蓝绿
};

  /// 自定义每个背景色对应的合适字体颜色（确保对比度）
  static const Map<String, Color> textColorMap = {
    'orange': Color(0xFF5D4037),     // 深棕
    'green': Color(0xFF1B5E20),      // 深绿
    'blue': Color(0xFF0D47A1),       // 深蓝
    'purple': Color(0xFF4A148C),     // 深紫
    'red': Color(0xFFB71C1C),        // 深红
    'teal': Color(0xFF00695C),       // 深青
    'amber': Color(0xFFE65100),      // 深橙
    'cyan': Color(0xFF006064),       // 深青
    'indigo': Color(0xFF1A237E),     // 深靛
    'pink': Color(0xFF880E4F),       // 深粉
    'lime': Color(0xFF827717),       // 深橄榄
    'deepOrange': Color(0xFFBF360C), // 深橙红
  };

  static final List<Color> courseColors = courseColorMap.values.toList();
  static final List<Color> textColors = textColorMap.values.toList();

  static Color getCourseColor(String name) {
    return courseColorMap[name] ?? courseColors[name.hashCode % courseColors.length];
  }

  static Color getWeekColor(String weekPattern) {
    if (weekPattern == 'all') return Colors.white;
    final week = int.tryParse(weekPattern.split(',').first) ?? 1;
    return week % 2 == 0 ? Colors.grey[100]! : Colors.white;
  }

  static Color getRandomColor([String? seed]) {
    final index = (seed?.hashCode ?? DateTime.now().millisecondsSinceEpoch) % courseColors.length;
    return courseColors[index];
  }

  static Color getContrastColor(Color bgColor) {
    // 先尝试从预设颜色中匹配
    final colorName = courseColorMap.keys.firstWhere(
      (key) => courseColorMap[key] == bgColor,
      orElse: () => ''
    );
    if (colorName.isNotEmpty && textColorMap.containsKey(colorName)) {
      return textColorMap[colorName]!;
    }

    // 没有预设则使用智能算法
    return textColors[(bgColor.value % textColors.length).abs()];
  }
}