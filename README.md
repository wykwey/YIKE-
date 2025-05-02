# 📅 课表应用 - Flutter Timetable

一个功能完善的跨平台课表应用，支持周视图、日视图和列表视图，界面美观，操作流畅。

## ✨ 核心功能

### 视图模式
- **周视图**：直观展示整周课程安排
- **日视图**：专注单日详细课程
- **列表视图**：按时间顺序查看所有课程

### 课程管理
- 添加/编辑/删除课程
- 设置课程颜色
- 多课表支持
- 课程冲突检测

### 其他功能
- 显示/隐藏周末课程
- 按周筛选课程
- 自适应主题
- 数据本地持久化

## 🖼️ 应用截图

TODO: 添加应用截图

## 🚀 快速开始

### 运行要求
- Flutter 3.0+
- Dart 2.17+

### 安装步骤
```bash
git clone https://github.com/wykwey/YIClass-.git
cd YIClass
flutter pub get
flutter run
```

## 📚 数据结构说明

### 课程模型
```dart
class Course {
  String id;
  String name;
  String location;
  String teacher;
  int color;
  List<Map<String, dynamic>> schedules;
}
```

### 时间安排格式
- `day`: 星期几 (1=周一, 2=周二...7=周日)
- `periods`: 节次列表 (如[1,2]表示1-2节)
- `weekPattern`: 周次模式，支持格式:
  - `'1-16'`: 1到16周
  - `'1,3,5'`: 第1,3,5周
  - `'1-3,5,7-9'`: 组合格式

## 🛠️ 技术架构

### 核心组件
- **状态管理**: ChangeNotifier
- **数据持久化**: SharedPreferences
- **UI框架**: Flutter Material Design

### 项目结构
```
lib/
├── components/    # 可复用组件
├── constants/     # 常量定义
├── data/         # 数据模型
├── services/     # 业务逻辑
├── states/       # 状态管理
├── utils/        # 工具类
└── views/        # 页面视图
```

## 🤝 贡献指南

欢迎提交Pull Request或Issue。提交前请确保：
1. 代码通过静态分析
2. 添加适当的单元测试
3. 更新相关文档

## ❓ 常见问题

**Q: 如何添加新课表?**
A: 点击底部导航栏"管理"按钮，然后选择"添加课表"

**Q: 课程时间冲突如何处理?**
A: 系统会自动检测并提示冲突

## 📄 开源协议

[MIT License](LICENSE)
