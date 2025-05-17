import 'package:flutter/material.dart';
import '../../data/schools/school_service.dart';
import './school_selection_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../states/timetable_state.dart';
import '../states/view_state.dart';
import '../states/week_state.dart';
import '../components/start_date_picker.dart';
import './time_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _showAboutDialog() {
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('关于'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.school, size: 48),
                SizedBox(height: 8),
                Text('课程表应用', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('版本: v1.0.0'),
                Text('© 2025 wykwe'),
                SizedBox(height: 16),
                Text('这是一个用于查看课程表的应用，支持每日、每周、列表等视图，并可设置课程周数、开课时间、是否显示周末等。'),
                SizedBox(height: 8),
                Text('开发者: wykwe'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timetableState = Provider.of<TimetableState>(context);
    final viewState = Provider.of<ViewState>(context);
    
    final timetable = timetableState.currentTimetable;
    if (timetable == null) return const SizedBox();

    final selectedView = viewState.selectedView;
    final totalWeeks = timetableState.totalWeeks;
    final showWeekend = viewState.showWeekend;
    final maxPeriods = timetableState.maxPeriods;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          ListTile(
            title: const Text('视图模式', style: TextStyle(color: Colors.black)),
            trailing: ToggleButtons(
              borderRadius: BorderRadius.circular(8),
              borderColor: Colors.grey,
              selectedColor: Colors.white,
              fillColor: Colors.blue,
              color: Colors.black87,
              isSelected: [
                selectedView == '周视图',
                selectedView == '日视图',
                selectedView == '列表视图'
              ],
              onPressed: (index) async {
                if (!mounted) return;
                final view = index == 0 ? '周视图' : index == 1 ? '日视图' : '列表视图';
                viewState.changeView(view, timetable);
                if (mounted) setState(() {});
              },
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('周')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('日')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('列表')),
              ],
            ),
          ),
          const StartDatePicker(),
          ListTile(
            title: const Text('总周数', style: TextStyle(color: Colors.black)),
            subtitle: Builder(
              builder: (context) {
                final startDateStr = timetable.settings['startDate'];
                final startDate = startDateStr != null 
                    ? DateTime.parse(startDateStr.toString())
                    : DateTime.now();
                final firstWeek = DateFormat('MM/dd').format(startDate);
                final weeksInt = totalWeeks is int ? totalWeeks : int.tryParse(totalWeeks.toString()) ?? 20;
                final lastWeek = DateFormat('MM/dd').format(
                  startDate.add(Duration(days: 7 * (weeksInt - 1)))
                );
                return Text('$firstWeek - $lastWeek');
              },
            ),
            trailing: SizedBox(
              width: 160,
              child: Slider(
                value: totalWeeks.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                label: '$totalWeeks',
                onChanged: (value) async {
                  if (mounted) {
                    timetableState.updateTotalWeeks(value.round());
                    setState(() {});
                  }
                },
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('是否显示周末', style: TextStyle(color: Colors.black)),
            subtitle: const Text('开启后将在课程表中显示周六和周日'),
            value: showWeekend,
            onChanged: (value) async {
              viewState.toggleWeekend(value, timetable);
              if (mounted) setState(() {});
            },
          ),
          ListTile(
            title: const Text('课程节数', style: TextStyle(color: Colors.black)),
            subtitle: Text('当前最大节数: $maxPeriods'),
            trailing: SizedBox(
              width: 160,
              child: Slider(
                value: maxPeriods.toDouble(),
                min: 1,
                max: 16,
                divisions: 15,
                label: '$maxPeriods',
                onChanged: (value) async {
                  if (mounted) {
                    timetableState.updateMaxPeriods(value.round());
                    setState(() {});
                  }
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('设置上课时间', style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TimeSettingsPage(),
                ),
              );
              if (mounted) setState(() {});
            },
          ),
          ListTile(
            title: const Text('切换学校', style: TextStyle(color: Colors.black)),
            subtitle: timetable.settings['school'] != null
                ? Text(timetable.settings['school'].toString())
                : const Text('未选择学校'),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SchoolSelectionPage(
                    currentSchool: timetable.settings['school']?.toString(),
                    onSchoolSelected: (selected) async {
                      final timetableState = Provider.of<TimetableState>(context, listen: false);
                      final timetable = timetableState.currentTimetable;
                      if (timetable != null) {
                        timetable.settings['school'] = selected;
                        await timetableState.updateTimetable(timetable);
                        final jsCode = await SchoolService.getJsCode(selected);
                        final eduUrl = await SchoolService.getEduUrl(selected);
                        timetable.settings['eduUrl'] = eduUrl;
                        timetable.settings['jsCode'] = jsCode;
                        await timetableState.updateTimetable(timetable);
                        if (mounted) setState(() {});
                      }
                    },
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('关于', style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }
}
