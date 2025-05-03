import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../data/timetable.dart';
import '../states/schedule_state.dart';

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
      ..addJavaScriptChannel(
        'DataChannel',
        onMessageReceived: (JavaScriptMessage message) async {
          try {
            final rawCourses = jsonDecode(message.message) as List;
            final timetable = Timetable.fromRawData(
              rawCourses.cast<Map<String, dynamic>>()
            );
            
            final state = Provider.of<ScheduleState>(context, listen: false);
            await state.addTimetable(timetable);
            
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop(); // 关闭弹窗
              Navigator.pop(context); // 返回首页
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('成功导入课表: ${timetable.name}')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop(); // 关闭弹窗
              Navigator.pop(context); // 返回首页
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

  void _importTimetable() async {
    const jsCode = r'''
async function scheduleHtmlProvider() {
  try {
    const weekInfoRes = await fetch("/kcb/api/week?schoolYear");
    if (!weekInfoRes.ok)
      throw new Error(`Failed to fetch week info: ${weekInfoRes.statusText}`);

    const weekInfoData = await weekInfoRes.json();
    const { schoolYear, schoolTerm, week } = weekInfoData.response;

    const courseRes = await fetch(
      `/kcb/api/course?schoolYear=${schoolYear}&schoolTerm=${schoolTerm}&week=${week}`,
      {
        method: "GET",
        headers: {
          "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        },
      }
    );

    if (!courseRes.ok)
      throw new Error(`Failed to fetch course data: ${courseRes.statusText}`);

    const courseData = await courseRes.json();
    return JSON.stringify(courseData);
  } catch (error) {
    console.error("课程表数据获取失败:", error);
    return "do not continue";
  }
}

function scheduleHtmlParser(stringify) {
  const parsedData = JSON.parse(stringify);

  function parseWeeks(weeksStr) {
    if (!weeksStr) return [];
    let weeks = [];
    weeksStr.split(",").forEach((range) => {
      range = range.trim();
      if (range.includes("-")) {
        const [start, end] = range.split("-").map(Number);
        weeks = weeks.concat(Array.from({ length: end - start + 1 }, (_, i) => start + i));
      } else {
        weeks.push(Number(range));
      }
    });
    return [...new Set(weeks)].sort((a, b) => a - b);
  }

  function parseSections(sectionStr) {
    if (!sectionStr) return [];
    return sectionStr.includes("-")
      ? sectionStr.split("-").map(Number)
      : [Number(sectionStr)];
  }

  function getDayOfWeek(dateStr) {
    if (!dateStr) return null;
    const formattedDateStr = dateStr.replace(
      /(\d{4})\/(\d{1,2})\/(\d{1,2})/,
      "$1-$2-$3"
    );
    const date = new Date(formattedDateStr);
    const day = date.getDay();
    return day === 0 ? 7 : day;
  }

  const transformedData = parsedData.response.flatMap((item) => {
    const dayOfWeek = getDayOfWeek(item.day);
    return item.data.map((course) => ({
      name: course.courseName,
      position: course.classRoom,
      teacher: course.teacherName,
      weeks: parseWeeks(course.weeks),
      day: dayOfWeek,
      sections: parseSections(course.section),
    }));
  });

  const uniqueCourses = [];
  const seen = new Set();

  for (const course of transformedData) {
    const key = `${course.name}-${course.position}-${course.weeks.join(",")}-${course.day}-${course.sections.join(",")}`;
    if (!seen.has(key)) {
      seen.add(key);
      uniqueCourses.push(course);
    }
  }

  return uniqueCourses;
}

(async () => {
  const scheduleData = await scheduleHtmlProvider();
  if (scheduleData !== "do not continue") {
    const result = scheduleHtmlParser(scheduleData);
    console.log('课程表数据:', result);
    DataChannel.postMessage(JSON.stringify(result));
  } else {
    console.log('获取课程表数据失败');
  }
})();
''';

    await _controller.runJavaScript(jsCode);
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
