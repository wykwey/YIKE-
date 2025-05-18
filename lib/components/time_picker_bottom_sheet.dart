import 'package:flutter/material.dart';

class TimePickerBottomSheet extends StatefulWidget {
  final String initialTimeRange;
  final Function(String) onTimeSelected;
  final int periodNumber;

  const TimePickerBottomSheet({
    super.key,
    required this.initialTimeRange,
    required this.onTimeSelected,
    required this.periodNumber,
  });

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  late int startHour, startMinute, endHour, endMinute, duration;

  @override
  void initState() {
    super.initState();
    final times = _parseTimeRange(widget.initialTimeRange);
    startHour = times[0];
    startMinute = times[1];
    endHour = times[2];
    endMinute = times[3];
    _adjustEndTimeIfNeeded();
    _calculateDuration();
  }

  // --- 时间处理逻辑 ---
  List<int> _parseTimeRange(String range) {
    final parts = range.split('-');
    if (parts.length == 2) {
      final start = parts[0].split(':');
      final end = parts[1].split(':');
      return [
        int.tryParse(start[0]) ?? 8,
        int.tryParse(start[1]) ?? 0,
        int.tryParse(end[0]) ?? 8,
        int.tryParse(end[1]) ?? 45,
      ];
    }
    return [8, 0, 8, 45];
  }

  void _adjustEndTimeIfNeeded() {
    final startTotal = startHour * 60 + startMinute;
    final endTotal = endHour * 60 + endMinute;
    if (endTotal <= startTotal) {
      final newEnd = startTotal + 45;
      endHour = newEnd ~/ 60;
      endMinute = newEnd % 60;
      if (endHour >= 24) {
        endHour = 23;
        endMinute = 59;
      }
    }
  }

  void _calculateDuration() {
    final start = startHour * 60 + startMinute;
    final end = endHour * 60 + endMinute;
    duration = (end - start).clamp(0, 1440);
  }

  String _formatTimeRange() {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(startHour)}:${pad(startMinute)}-${pad(endHour)}:${pad(endMinute)}';
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Text(
              '请调节整节课时间（本节$duration分钟）',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
            ),
          ),
          const SizedBox(height: 30),
          _TimeRangeSelector(
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            onStartHourChanged: (v) => setState(() {
              startHour = v;
              _adjustEndTimeIfNeeded();
              _calculateDuration();
            }),
            onStartMinuteChanged: (v) => setState(() {
              startMinute = v;
              _adjustEndTimeIfNeeded();
              _calculateDuration();
            }),
            onEndHourChanged: (v) => setState(() {
              endHour = v;
              _calculateDuration();
            }),
            onEndMinuteChanged: (v) => setState(() {
              endMinute = v;
              _calculateDuration();
            }),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      if ((endHour * 60 + endMinute) <= (startHour * 60 + startMinute)) {
                        _adjustEndTimeIfNeeded();
                      }
                      widget.onTimeSelected(_formatTimeRange());
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('确定'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _TimeRangeSelector extends StatelessWidget {
  final int startHour, startMinute, endHour, endMinute;
  final ValueChanged<int> onStartHourChanged, onStartMinuteChanged, onEndHourChanged, onEndMinuteChanged;
  const _TimeRangeSelector({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.onStartHourChanged,
    required this.onStartMinuteChanged,
    required this.onEndHourChanged,
    required this.onEndMinuteChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 合法结束时间区间逻辑合并
    final endHourMin = startHour;
    final endHourMax = 23;
    int endMinuteMin, endMinuteMax;
    if (endHour == startHour) {
      endMinuteMin = startMinute + 1;
      endMinuteMax = 59;
      if (endMinuteMin > 59) {
        // 如果分钟溢出，小时应自动跳到下一个小时，分钟从0开始
        endMinuteMin = 0;
        endMinuteMax = 59;
      }
    } else {
      endMinuteMin = 0;
      endMinuteMax = 59;
    }
    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(child: _TimeWheel(value: startHour, min: 0, max: 23, onChanged: onStartHourChanged, suffix: '时')),
                Expanded(child: _TimeWheel(value: startMinute, min: 0, max: 59, onChanged: onStartMinuteChanged, suffix: '分')),
              ],
            ),
          ),
          const SizedBox(width: 20, child: Center(child: Text('-', style: TextStyle(fontSize: 28))),),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(child: _TimeWheel(value: endHour, min: endHourMin, max: endHourMax, onChanged: onEndHourChanged, suffix: '时')),
                Expanded(child: _TimeWheel(value: endMinute, min: endMinuteMin, max: endMinuteMax, onChanged: onEndMinuteChanged, suffix: '分')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeWheel extends StatelessWidget {
  final int value, min, max;
  final ValueChanged<int> onChanged;
  final String suffix;
  const _TimeWheel({required this.value, required this.min, required this.max, required this.onChanged, required this.suffix});

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      itemExtent: 50,
      diameterRatio: 20.0,
      perspective: 0.001,
      physics: const FixedExtentScrollPhysics(),
      controller: FixedExtentScrollController(initialItem: value - min),
      onSelectedItemChanged: (i) => onChanged(i + min),
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          final realValue = index + min;
          if (realValue < min || realValue > max) return const SizedBox.shrink();
          final isSelected = realValue == value;
          return Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  realValue.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: isSelected ? 24 : 20,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue.shade400 : Colors.black38,
                  ),
                ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(suffix, style: TextStyle(fontSize: 12, color: Colors.blue.shade400)),
                  ),
              ],
            ),
          );
        },
        childCount: max - min + 1,
      ),
      overAndUnderCenterOpacity: 0.5,
      magnification: 1.05,
    );
  }
} 