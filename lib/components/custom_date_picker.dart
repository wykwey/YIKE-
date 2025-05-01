import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCalendarDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateChanged;

  const CustomCalendarDatePicker({
    super.key,
    this.initialDate,
    this.onDateChanged,
  });

  @override
  State<CustomCalendarDatePicker> createState() => _CustomCalendarDatePickerState();
}

class _CustomCalendarDatePickerState extends State<CustomCalendarDatePicker> {
  late DateTime _displayedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = widget.initialDate ?? DateTime.now();
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

  List<Widget> _buildCalendarDays() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final int weekdayOffset = firstDayOfMonth.weekday % 7;

    final List<Widget> dayWidgets = [];

    for (int i = 0; i < weekdayOffset; i++) {
      dayWidgets.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final current = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      final isSelected = _selectedDate != null &&
          _selectedDate!.year == current.year &&
          _selectedDate!.month == current.month &&
          _selectedDate!.day == current.day;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() => _selectedDate = current);
            widget.onDateChanged?.call(current);
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : null,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return dayWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final monthTitle = DateFormat.yMMMM().format(_displayedMonth);
    final isWide = MediaQuery.of(context).size.width > 600;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: _goToPreviousMonth, icon: const Icon(Icons.chevron_left)),
              Text(monthTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: _goToNextMonth, icon: const Icon(Icons.chevron_right)),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('日'), Text('一'), Text('二'), Text('三'),
              Text('四'), Text('五'), Text('六'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _buildCalendarDays(),
          ),
        ],
      ),
    );
  }
}