import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../states/timetable_state.dart';
import '../constants/app_constants.dart';
import '../components/start_date_picker.dart';
import '../components/time_picker_bottom_sheet.dart';

class TimeSettingsPage extends StatefulWidget {
  const TimeSettingsPage({super.key});

  @override
  State<TimeSettingsPage> createState() => _TimeSettingsPageState();
}

class _TimeSettingsPageState extends State<TimeSettingsPage> {
  late Map<String, String> _periodTimes;
  DateTime? _selectedDate;
  int _maxPeriods = AppConstants.defaultMaxPeriods;
  bool _isSameDuration = false;
  String _sameDurationValue = '';

  @override
  void initState() {
    super.initState();
    final timetableState = Provider.of<TimetableState>(context, listen: false);
    final timetable = timetableState.currentTimetable;
    final Map<String, dynamic> periodTimesData = timetable?.settings['periodTimes'] ?? AppConstants.defaultPeriodTimes;
    
    _periodTimes = {};
    periodTimesData.forEach((key, value) {
      _periodTimes[key] = value.toString();
    });
    
    _maxPeriods = timetable?.settings['maxPeriods'] ?? AppConstants.defaultMaxPeriods;
    _selectedDate = timetable?.settings['startDate'] != null
        ? DateTime.tryParse(timetable!.settings['startDate'].toString())
        : null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final currentDate = _selectedDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveSettings() async {
    final timetableState = Provider.of<TimetableState>(context, listen: false);
    final timetable = timetableState.currentTimetable;
    if (timetable == null) return;
    
    final newTimes = <String, String>{};
    _periodTimes.forEach((key, value) {
      newTimes[key] = value;
    });
    
    timetable.settings['periodTimes'] = newTimes;
    timetable.settings['maxPeriods'] = _maxPeriods;
    if (_selectedDate != null) {
      timetable.settings['startDate'] = _selectedDate.toString();
    }
    await timetableState.updateTimetable(timetable);
    if (mounted) Navigator.pop(context);
  }

  void _updateMaxPeriods(int value) {
    setState(() {
      _maxPeriods = value;
      for (int i = 1; i <= _maxPeriods; i++) {
        _periodTimes.putIfAbsent(i.toString(), () => AppConstants.defaultPeriodTimes[i.toString()]?.toString() ?? '');
      }
      _periodTimes.removeWhere((key, _) => int.parse(key) > _maxPeriods);
    });
  }

  void _applySameDurationDuration() {
    // 以 08:00 为起点，依次推算每节课时间
    int duration = int.tryParse(_sameDurationValue) ?? 45;
    DateTime start = DateTime(2000, 1, 1, 8, 0);
    for (int i = 1; i <= _maxPeriods; i++) {
      final end = start.add(Duration(minutes: duration));
      final timeStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}-'
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
      _periodTimes[i.toString()] = timeStr;
      start = end;
    }
    setState(() {});
  }

  List<int> _morningPeriods() => [1, 2, 3, 4].where((i) => i <= _maxPeriods).toList();
  List<int> _afternoonPeriods() => [5, 6, 7, 8, 9].where((i) => i <= _maxPeriods).toList();
  List<int> _eveningPeriods() => [10, 11, 12, 13, 14, 15, 16].where((i) => i <= _maxPeriods).toList();

  // 将数字转换为汉字
  String _getChineseNumber(int number) {
    const chineseNumbers = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十', '十一', '十二', '十三', '十四', '十五', '十六'];
    if (number >= 1 && number <= 16) {
      return chineseNumbers[number - 1];
    }
    return number.toString();
  }

  Widget _buildTimeList(String title, List<int> periods) {
    if (periods.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(title, style: const TextStyle(color: Colors.grey)),
        ),
        ...periods.map((period) => InkWell(
          onTap: _isSameDuration ? null : () => _showTimePickerBottomSheet(period),
          child: ListTile(
            title: Text(
              '第${_getChineseNumber(period)}节',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _periodTimes[period.toString()] ?? "未设置",
                  style: TextStyle(
                    color: _isSameDuration ? Colors.grey : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: _isSameDuration ? Colors.grey : Colors.black54,
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  void _showTimePickerBottomSheet(int period) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TimePickerBottomSheet(
          initialTimeRange: _periodTimes[period.toString()] ?? '08:00-08:45',
          periodNumber: period,
          onTimeSelected: (timeRange) {
            setState(() {
              _periodTimes[period.toString()] = timeRange;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程时间设置'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSettings,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          ListTile(
            title: const Text('学期开始日期', style: TextStyle(color: Colors.black)),
            subtitle: Text(
              Provider.of<TimetableState>(context, listen: false).currentTimetable?.settings['startDate'] != null
                  ? DateFormat('yyyy-MM-dd').format(DateTime.parse(Provider.of<TimetableState>(context, listen: false).currentTimetable!.settings['startDate'].toString()))
                  : '未设置',
            ),
            trailing: const Icon(Icons.edit_calendar),
            onTap: () async {
              final timetableState = Provider.of<TimetableState>(context, listen: false);
              final timetable = timetableState.currentTimetable;
              final currentDate = timetable?.settings['startDate'] != null
                  ? DateTime.parse(timetable!.settings['startDate'].toString())
                  : DateTime.now();
              await showDialog(
                context: context,
                builder: (_) => SimpleDatePicker(
                  initialDate: currentDate,
                  onDateSelected: (picked) async {
                    timetable?.settings['startDate'] = picked.toString();
                    await timetableState.updateTimetable(timetable!);
                    if (mounted) setState(() {});
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('最大节数:', style: TextStyle(color: Colors.black)),
                Expanded(
                  child: Slider(
                    value: _maxPeriods.toDouble(),
                    min: 1,
                    max: 16,
                    divisions: 15,
                    label: '$_maxPeriods',
                    onChanged: (value) => _updateMaxPeriods(value.round()),
                  ),
                ),
                Text('$_maxPeriods 节'),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('每节课时长相同', style: TextStyle(color: Colors.black)),
            subtitle: const Text('如45分钟，自动推算每节时间'),
            value: _isSameDuration,
            onChanged: (val) {
              setState(() {
                _isSameDuration = val;
                if (val && _sameDurationValue.isNotEmpty) {
                  _applySameDurationDuration();
                }
              });
            },
          ),
          if (_isSameDuration)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('统一时长(分钟):'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        _sameDurationValue = val;
                        if (_isSameDuration && val.isNotEmpty) {
                          _applySameDurationDuration();
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: '45',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_sameDurationValue.isNotEmpty) {
                        _applySameDurationDuration();
                      }
                    },
                    child: const Text('应用'),
                  ),
                ],
              ),
            ),
          const Divider(),
          _buildTimeList('上午', _morningPeriods()),
          _buildTimeList('下午', _afternoonPeriods()),
          _buildTimeList('晚上', _eveningPeriods()),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
} 