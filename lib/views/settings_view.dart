import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/settings.dart';
import '../states/schedule_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: AppSettings.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('zh', 'CN'),
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked != null) {
      setState(() {
        AppSettings.saveStartDate(picked);
      });
    }
  }

  void _showTimeSettingsDialog() {
    final controllers = Map.fromEntries(
      AppSettings.periodTimes.entries.map((e) => 
        MapEntry(e.key, TextEditingController(text: e.value)))
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('课程时间设置'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var entry in controllers.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text('第${entry.key}节:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: entry.value,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final newTimes = Map.fromEntries(
                controllers.entries.map((e) => 
                  MapEntry(e.key, e.value.text))
              );
              AppSettings.savePeriodTimes(newTimes);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
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
    final dateStr = DateFormat('yyyy-MM-dd').format(AppSettings.startDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('视图模式', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(8),
                    borderColor: Colors.grey,
                    selectedColor: Colors.white,
                    fillColor: Colors.blue,
                    color: Colors.black87,
                    isSelected: [
                      AppSettings.selectedView == '周视图',
                      AppSettings.selectedView == '日视图',
                      AppSettings.selectedView == '列表视图'
                    ],
                    onPressed: (index) async {
                      final view = index == 0 ? '周视图' : index == 1 ? '日视图' : '列表视图';
                      await AppSettings.saveViewPreference(view);
                      final state = context.read<ScheduleState>();
                      state.changeView(view);
                      setState(() {});
                    },
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('周')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('日')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('列表')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('开始上课日期'),
                  subtitle: Text(dateStr),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: _pickStartDate,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.timeline),
                  title: const Text('总周数'),
                  subtitle: Text('${AppSettings.totalWeeks} 周'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Slider(
                    value: AppSettings.totalWeeks.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    label: '${AppSettings.totalWeeks}',
                    onChanged: (value) {
                      setState(() {
                        AppSettings.saveTotalWeeks(value.round());
                      });
                    },
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('是否显示周末'),
                  subtitle: const Text('开启后将在课程表中显示周六和周日'),
                  secondary: const Icon(Icons.weekend),
                  value: AppSettings.showWeekend,
                  onChanged: (value) async {
                    await AppSettings.saveShowWeekend(value);
                    final state = context.read<ScheduleState>();
                    state.toggleWeekend(value);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('课程节数'),
                  subtitle: Text('${AppSettings.maxPeriods} 节'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Slider(
                    value: AppSettings.maxPeriods.toDouble(),
                    min: 1,
                    max: 16,
                    divisions: 15,
                    label: '${AppSettings.maxPeriods}',
                    onChanged: (value) {
                      setState(() {
                        AppSettings.saveMaxPeriods(value.round());
                      });
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('课程时间设置'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _showTimeSettingsDialog,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('关于'),
              subtitle: const Text('查看应用信息'),
              onTap: _showAboutDialog,
            ),
          ),
        ],
      ),
    );
  }
}
