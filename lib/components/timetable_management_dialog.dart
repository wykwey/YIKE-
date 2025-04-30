import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/schedule_state.dart';
import '../data/timetable.dart';

class TimetableManagementDialog extends StatelessWidget {
  const TimetableManagementDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ScheduleState>();
    final textController = TextEditingController();

    return AlertDialog(
      title: const Text('课表管理'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: state.timetables.map((timetable) {
                  return ListTile(
                    title: Text(timetable.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (timetable.id == state.currentTimetableId)
                          const Icon(Icons.check, color: Colors.green),
                        if (!timetable.isDefault)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => state.removeTimetable(timetable.id),
                          ),
                      ],
                    ),
                    onTap: () => state.switchTimetable(timetable.id),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: '新课表名称',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (textController.text.isNotEmpty) {
              state.addTimetable(Timetable(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: textController.text,
                courses: [],
              ));
              Navigator.pop(context);
            }
          },
          child: const Text('添加'),
        ),
      ],
    );
  }
}
