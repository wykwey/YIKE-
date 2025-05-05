import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'start_date_picker.dart';

class TimeSettingsDialog extends StatefulWidget {
  final Map<String, TextEditingController> controllers;
  final DateTime? initialStartDate;
  final Function(Map<String, String>, DateTime?)? onSave;

  const TimeSettingsDialog({
    super.key,
    required this.controllers,
    this.initialStartDate,
    this.onSave,
  });

  @override
  State<TimeSettingsDialog> createState() => _TimeSettingsDialogState();
}

class _TimeSettingsDialogState extends State<TimeSettingsDialog> {
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialStartDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!mounted) return;
    
    final currentDate = _selectedDate ?? DateTime.now();
    
    await showDialog(
      context: context,
      builder: (_) => SimpleDatePicker(
        initialDate: currentDate,
        onDateSelected: (picked) {
          if (picked != _selectedDate) {
            setState(() {
              _selectedDate = picked;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        '课程时间设置',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Text('学期开始日期:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                            : '未设置',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              ...widget.controllers.entries.map((entry) {
                final period = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          '第$period节',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.access_time),
                            hintText: '如 08:00-08:45',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            final newTimes = <String, String>{};
            for (var entry in widget.controllers.entries) {
              newTimes[entry.key] = entry.value.text;
            }
            if (widget.onSave != null) {
              widget.onSave!(newTimes, _selectedDate);
            }
            Navigator.pop(context, true);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}