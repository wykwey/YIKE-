import 'package:flutter/material.dart';

class TimeSettingsDialog extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Function(Map<String, String>)? onSave;

  const TimeSettingsDialog({
    super.key,
    required this.controllers,
    this.onSave,
  });

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
            children: controllers.entries.map((entry) {
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
            }).toList(),
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
            for (var entry in controllers.entries) {
              newTimes[entry.key] = entry.value.text;
            }
            if (onSave != null) {
              onSave!(newTimes);
            }
            Navigator.pop(context, true);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
