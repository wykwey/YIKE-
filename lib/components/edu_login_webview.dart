import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EduLoginWebView extends StatefulWidget {
  final String schoolUrl;

  const EduLoginWebView({
    required this.schoolUrl,
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

  void _importTimetable() {
    // TODO: 实现导入课表逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入课表功能开发中'))
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用帮助'),
        content: const Text('1. 切换UA: 切换电脑/手机版界面\n'
                          '2. 导入课表: 从教务系统导入课表\n'
                          '3. 使用帮助: 查看本帮助信息'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
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
            icon: const Icon(Icons.computer),
            tooltip: '切换电脑版',
            onPressed: _toggleUserAgent,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: '导入课表',
            onPressed: _importTimetable,
          ),
          IconButton(
            icon: const Icon(Icons.help),
            tooltip: '使用帮助',
            onPressed: _showHelp,
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
