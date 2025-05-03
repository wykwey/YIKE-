import 'package:flutter/material.dart';
import '../../data/schools/school_service.dart';
import './school_selection_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../states/schedule_state.dart';
import '../data/settings.dart';
import '../components/start_date_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _selectedSchool;

  @override
  void initState() {
    super.initState();
    _loadSelectedSchool();
  }

  Future<void> _loadSelectedSchool() async {
    final schools = await SchoolService.getSchoolNames();
    if (schools.isNotEmpty && mounted) {
      setState(() {
        _selectedSchool = schools.first;
      });
    }
  }
  Future<void> _showTimeSettingsDialog() async {
    if (!mounted) return;

    final state = Provider.of<ScheduleState>(context, listen: false);
    final timetable = state.currentTimetable;
    if (timetable == null) return;

    final periodTimes = timetable.settings['periodTimes'] ?? AppSettings.defaultPeriodTimes;
    final maxPeriods = timetable.settings['maxPeriods'] ?? 16;

    await AppSettings.showTimeSettingsDialog(
      context,
      periodTimes is Map ? Map<String, String>.from(periodTimes) : AppSettings.defaultPeriodTimes,
      maxPeriods is int ? maxPeriods : 16,
      (newTimes) async {
        timetable.settings['periodTimes'] = newTimes;
        await state.updateTimetable(timetable);
        if (mounted) setState(() {});
      },
    );
  }

  void _showAboutDialog() {
    if (!mounted) return;

    showAboutDialog(
      context: context,
      applicationName: '课程表应用',
      applicationVersion: 'v1.0.0',
      applicationLegalese: '© 2025 wykwe',
      applicationIcon: const Icon(Icons.school, size: 48),
      children: const [
        SizedBox(height: 8),
        Text('这是一个用于查看课程表的应用，支持每日、每周、列表等视图，并可设置课程周数、开课时间、是否显示周末等。'),
        SizedBox(height: 8),
        Text('开发者: wykwe'),
        Text('版本: 1.0.0'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ScheduleState>(context);
    final timetable = state.currentTimetable;
    if (timetable == null) return const SizedBox();

    final selectedView = timetable.settings['selectedView'] ?? '周视图';
    final totalWeeks = timetable.settings['totalWeeks'] ?? 20;
    final showWeekend = state.showWeekend;
    final maxPeriods = timetable.settings['maxPeriods'] ?? 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;
          return ListView(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('视图模式', 
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16, 
                          fontWeight: FontWeight.bold
                        )),
                      ToggleButtons(
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
                          state.changeView(view);

                          if (mounted) setState(() {});
                        },
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8), 
                            child: Text('周', style: TextStyle(fontSize: isSmallScreen ? 12 : 14))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8), 
                            child: Text('日', style: TextStyle(fontSize: isSmallScreen ? 12 : 14))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8), 
                            child: Text('列表', style: TextStyle(fontSize: isSmallScreen ? 12 : 14))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              const StartDatePicker(),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.timeline),
                      title: const Text('总周数'),
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
                          return Text('$firstWeek - $lastWeek', 
                            style: TextStyle(fontSize: isSmallScreen ? 12 : 14));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Slider(
                        value: totalWeeks.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: '$totalWeeks',
                        onChanged: (value) async {
                          if (mounted) {
                            timetable.settings['totalWeeks'] = value.round();
                            await state.updateTimetable(timetable);
                            setState(() {});
                          }
                        },
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('是否显示周末'),
                      subtitle: const Text('开启后将在课程表中显示周六和周日'),
                      secondary: const Icon(Icons.weekend),
                      value: showWeekend,
                      onChanged: (value) async {
                        state.toggleWeekend(value);
                        await state.updateTimetable(timetable);
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.schedule),
                      title: Text('课程节数'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Slider(
                        value: maxPeriods.toDouble(),
                        min: 1,
                        max: 16,
                        divisions: 15,
                        label: '$maxPeriods',
                        onChanged: (value) async {
                          if (mounted) {
                            timetable.settings['maxPeriods'] = value.round();
                            await state.updateTimetable(timetable);
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text('设置上课时间', style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showTimeSettingsDialog,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.school),
                      title: const Text('切换学校'),
                      subtitle: _selectedSchool != null 
                          ? Text(_selectedSchool!)
                          : const Text('加载中...'),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SchoolSelectionPage(
                              currentSchool: _selectedSchool,
                              onSchoolSelected: (selected) async {
                                if (mounted) {
                                  setState(() => _selectedSchool = selected);
                                  final state = Provider.of<ScheduleState>(context, listen: false);
                                  final timetable = state.currentTimetable;
                                  if (timetable != null) {
                                    timetable.settings['school'] = selected;
                                    await state.updateTimetable(timetable);
                                    
                                    final jsCode = await SchoolService.getJsCode(selected);
                                    final eduUrl = await SchoolService.getEduUrl(selected);
                                    timetable.settings['eduUrl'] = eduUrl;
                                    timetable.settings['jsCode'] = jsCode;
                                    await state.updateTimetable(timetable);
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.info),
                  title: Text('关于', style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showAboutDialog,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
