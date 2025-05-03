import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../data/timetable.dart';
import '../states/schedule_state.dart';
import '../data/schools/school_service.dart';

class EduLoginWebView extends StatefulWidget {
  final String schoolUrl;
  final String jsCode;

  const EduLoginWebView({
    required this.schoolUrl,
    required this.jsCode,
    super.key,
  });

  @override
  State<EduLoginWebView> createState() => _EduLoginWebViewState();
}

class _EduLoginWebViewState extends State<EduLoginWebView> {
  late final WebViewController _controller;
  bool _isDesktopUA = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'DataChannel',
        onMessageReceived: (JavaScriptMessage message) async {
          try {
            final rawCourses = jsonDecode(message.message) as List;
            final state = Provider.of<ScheduleState>(context, listen: false);
            final timetable = state.currentTimetable;
            
            final newTimetable = Timetable.fromRawData(
              rawCourses.cast<Map<String, dynamic>>(),
              settings: timetable?.settings ?? {}
            );
            await state.addTimetable(newTimetable);
            
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('成功导入课表: ${newTimetable.name}')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('导入失败: ${e.toString()}')),
              );
            }
          }
        },
      )
      ..loadRequest(Uri.parse(widget.schoolUrl));
  }

  void _toggleUserAgent() async {
    setState(() {
      _isDesktopUA = !_isDesktopUA;
    });

    final newUA = _isDesktopUA
        ? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        : null;

    await _controller.setUserAgent(newUA);
    await _controller.reload();
  }

  Future<void> _importTimetable() async {
    final state = Provider.of<ScheduleState>(context, listen: false);
    final timetable = state.currentTimetable;
    final schoolName = timetable?.settings['school'] as String?;
    final jsCode = await SchoolService.getJsCode(schoolName ?? '');
    
    if (jsCode == null || jsCode.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未找到该学校的导入脚本')),
        );
      }
      return;
    }

    await _controller.runJavaScript(jsCode);
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用帮助'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem(Icons.refresh, '刷新页面', '重新加载当前页面'),
              _buildHelpItem(Icons.phone_android, '切换视图', '在手机版和电脑版界面之间切换'),
              _buildHelpItem(Icons.download, '导入课表', '从教务系统导入当前课表'),
              _buildHelpItem(Icons.help_outline, '常见问题', '1. 确保已登录教务系统\n2. 如遇页面显示问题，尝试切换视图\n3. 导入失败请检查网络连接'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('教务系统登录'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: '刷新页面',
          onPressed: () => _controller.reload(),
        ),
        IconButton(
          icon: Icon(_isDesktopUA ? Icons.phone_android : Icons.computer),
          tooltip: _isDesktopUA ? '切换手机版' : '切换电脑版',
          onPressed: _toggleUserAgent,
        ),
        IconButton(
          icon: const Icon(Icons.download),
          tooltip: '导入课表',
          onPressed: _importTimetable,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'help',
              child: ListTile(
                leading: Icon(Icons.help),
                title: Text('使用帮助'),
              ),
            ),
            const PopupMenuItem(
              value: 'about',
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('关于'),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'help') {
              _showHelp();
            } else {
              showAboutDialog(
                context: context,
                applicationName: '小爱课程表',
                applicationVersion: '1.0.0',
              );
            }
          },
        ),
      ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
