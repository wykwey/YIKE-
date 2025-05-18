import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'package:intl/intl.dart';

class WeekHeader extends StatelessWidget {
  final bool showWeekend;
  final int currentWeek;
  final Map<String, dynamic> timetableSettings;

  const WeekHeader({
    super.key,
    required this.showWeekend,
    required this.currentWeek,
    required this.timetableSettings,
  });

  @override
  Widget build(BuildContext context) {
    final startDateString = timetableSettings['startDate'];
    final startDate = startDateString != null 
        ? DateTime.parse(startDateString.toString()) 
        : null;
    final month = startDate != null
        ? (startDate.add(Duration(days: 7 * (currentWeek - 1))).month)
        : DateTime.now().month;
    final monthText = '$month月';

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        color: Colors.white,
      ),
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          _buildMonthCell(monthText),
          Expanded(
            child: Row(
              children: List.generate(showWeekend ? 7 : 5, (index) {
                return Expanded(
                  child: _buildDayCell(index, startDate),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCell(String monthText) {
    final num = monthText.replaceAll('月', '');
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            num,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
          Text(
            '月',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int index, DateTime? startDate) {
    final weekday = AppConstants.weekDays[index];
    final date = startDate?.add(Duration(days: 7 * (currentWeek - 1) + index));
    
    return Container(
      height: 40,
      decoration: BoxDecoration(),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weekday,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
          if (date != null)
            Text(
              DateFormat('MM/dd').format(date),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
