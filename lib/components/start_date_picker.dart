import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../states/timetable_state.dart';
import '../states/week_state.dart';

// 自定义日期选择器组件
class SimpleDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const SimpleDatePicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<SimpleDatePicker> createState() => _SimpleDatePickerState();
}

class _SimpleDatePickerState extends State<SimpleDatePicker> {
  late DateTime _displayedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
  }

  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  List<Widget> _buildDayHeaders() {
    const days = ['一', '二', '三', '四', '五', '六', '日'];
    return days
        .map((d) => Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold))))
        .toList();
  }

  List<Widget> _buildCalendarDays() {
    final firstDay = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final weekdayOffset = (firstDay.weekday + 6) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(_displayedMonth.year, _displayedMonth.month);
    final totalCells = weekdayOffset + daysInMonth;

    return List.generate(totalCells, (index) {
      if (index < weekdayOffset) return const SizedBox();

      final day = index - weekdayOffset + 1;
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      final isSelected = _selectedDate?.year == date.year &&
          _selectedDate?.month == date.month &&
          _selectedDate?.day == date.day;

      return GestureDetector(
        onTap: () => setState(() => _selectedDate = date),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : null,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = DateFormat('yyyy年MM月').format(_displayedMonth);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    final headerFontSize = isSmallScreen ? 14.0 : 16.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isSmallScreen ? screenWidth - 32 : 400),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _goToPreviousMonth,
                    icon: const Icon(Icons.chevron_left),
                    iconSize: isSmallScreen ? 20 : 24,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: headerFontSize),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _goToNextMonth,
                    icon: const Icon(Icons.chevron_right),
                    iconSize: isSmallScreen ? 20 : 24,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1,
                mainAxisSpacing: isSmallScreen ? 2 : 4,
                crossAxisSpacing: isSmallScreen ? 2 : 4,
                children: [
                  ..._buildDayHeaders(),
                  ..._buildCalendarDays(),
                ],
              ),
              SizedBox(height: isSmallScreen ? 8 : 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('取消', style: TextStyle(fontSize: fontSize)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      if (_selectedDate != null) {
                        widget.onDateSelected(_selectedDate!);
                      }
                      Navigator.pop(context);
                    },
                    child: Text('确定', style: TextStyle(fontSize: fontSize)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 开始日期选择器组件
class StartDatePicker extends StatelessWidget {
  const StartDatePicker({super.key});

  Future<void> _pickStartDate(BuildContext context) async {
    if (!context.mounted) return;

    final timetableState = Provider.of<TimetableState>(context, listen: false);
    final weekState = Provider.of<WeekState>(context, listen: false);
    final timetable = timetableState.currentTimetable;
    if (timetable == null) return;

    final currentDate = timetable.settings['startDate'] != null
        ? DateTime.parse(timetable.settings['startDate'].toString())
        : DateTime.now();

    await showDialog(
      context: context,
      builder: (_) => SimpleDatePicker(
        initialDate: currentDate,
        onDateSelected: (picked) async {
          timetable.settings['startDate'] = picked.toString();
          await timetableState.updateTimetable(timetable);
          // 更新当前周数
          if (context.mounted) {
            await weekState.loadFromTimetable(timetable);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timetableState = Provider.of<TimetableState>(context);
    final timetable = timetableState.currentTimetable;
    if (timetable == null) return const SizedBox();

    final dateStr = timetable.settings['startDate'] != null
        ? DateFormat('yyyy-MM-dd').format(
            DateTime.parse(timetable.settings['startDate'].toString()))
        : '未设置';

    return ListTile(
      title: const Text('开始上课日期', style: TextStyle(color: Colors.black)),
      subtitle: Text(dateStr),
      trailing: const Icon(Icons.edit_calendar),
      onTap: () => _pickStartDate(context),
    );
  }
}
