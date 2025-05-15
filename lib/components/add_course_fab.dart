import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../states/schedule_state.dart';
import '../data/timetable.dart';
import '../data/schools/school_config.dart';
import './edu_login_webview.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class AddCourseFab extends StatefulWidget {
  const AddCourseFab({super.key});

  @override
  State<AddCourseFab> createState() => _AddCourseFabState();
}

class _AddCourseFabState extends State<AddCourseFab> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  Offset _position = const Offset(16, 16); // 初始位置

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1),
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1),
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  Future<void> _importFromEduSystem() async {
    _toggleMenu();
    final state = context.read<ScheduleState>();
    final timetable = state.currentTimetable;
    final schoolName = timetable?.settings['school'] as String?;

    if (schoolName == null || schoolName.isEmpty) {
      _showErrorSnackBar('请先选择学校');
      return;
    }

    try {
      final schoolConfig = SchoolConfig.findByName(schoolName);
      if (schoolConfig == null) {
        _showErrorSnackBar('找不到该学校的配置');
        return;
      }

      final url = schoolConfig.eduSystemUrl;
      final jsCode = schoolConfig.jsCode;

      if (url.isEmpty || jsCode.isEmpty) {
        _showErrorSnackBar('该学校暂不支持导入');
        return;
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EduLoginWebView(
              schoolUrl: url,
              jsCode: jsCode,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('获取学校配置失败: ${e.toString()}');
    }
  }

  Future<void> _importFromFile() async {
    _toggleMenu();
    final state = context.read<ScheduleState>();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = result.files.single;
        final content = utf8.decode(file.bytes!);
        final jsonData = jsonDecode(content);
        List<Timetable> timetables = [];

        if (jsonData is List) {
          timetables = jsonData.map((e) => Timetable.fromJson(e as Map<String, dynamic>)).toList();
        } else if (jsonData is Map) {
          timetables = [Timetable.fromJson(jsonData as Map<String, dynamic>)];
        }

        for (var timetable in timetables) {
          await state.addTimetable(timetable);
        }

        _showSuccessSnackBar('成功导入${timetables.length}个课表');
      }
    } catch (e) {
      _showErrorSnackBar('导入失败: ${e.toString()}');
    }
  }

  Future<void> _exportToFile() async {
    _toggleMenu();
    final state = context.read<ScheduleState>();
    final timetables = state.timetables;
    final jsonData = timetables.map((t) => t.toJson()).toList();
    final content = jsonEncode(jsonData);
    final bytes = utf8.encode(content);

    if (kIsWeb) {
      // Web 平台使用 share_plus 插件
      await Share.shareXFiles(
        [XFile.fromData(bytes, name: 'timetable.json')],
        text: '课表数据',
      );
    } else {
      // 移动平台使用文件系统
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/timetable.json');
      await file.writeAsBytes(bytes);
      
      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: '课表数据',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        Positioned(
          right: _position.dx,
          bottom: _position.dy,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isExpanded) ...[
                _buildCircularButton(
                  icon: Icons.school,
                  onTap: _importFromEduSystem,
                  showScale: true,
                ),
                const SizedBox(height: 16),
                _buildCircularButton(
                  icon: Icons.upload_file,
                  onTap: _importFromFile,
                  showScale: true,
                ),
                const SizedBox(height: 16),
                _buildCircularButton(
                  icon: Icons.download,
                  onTap: _exportToFile,
                  showScale: true,
                ),
                const SizedBox(height: 16),
              ],
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _position = Offset(
                      _position.dx - details.delta.dx,
                      _position.dy - details.delta.dy,
                    );
                  });
                },
                child: _buildCircularButton(
                  icon: Icons.add,
                  onTap: _toggleMenu,
                  showScale: false,
                  child: RotationTransition(
                    turns: _rotateAnimation,
                    child: Icon(
                      Icons.add,
                      color: Colors.blue[700],
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool showScale,
    Widget? child,
  }) {
    Widget button = FloatingActionButton(
      onPressed: onTap,
      backgroundColor: Colors.white,
      elevation: 4,
      child: child ?? Icon(
        icon,
        color: Colors.blue[700],
        size: 28,
      ),
    );

    if (showScale) {
      button = ScaleTransition(
        scale: _scaleAnimation,
        child: button,
      );
    }

    return button;
  }
}