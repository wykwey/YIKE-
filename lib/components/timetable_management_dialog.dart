import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/timetable_state.dart';
import '../data/timetable.dart';

class TimetableManagementDialog extends StatelessWidget {
  const TimetableManagementDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final timetableState = context.watch<TimetableState>();
    final textController = TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('课表管理', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...timetableState.timetables.map((timetable) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(timetable.name),
                      leading: const Icon(Icons.calendar_today_outlined, color: Colors.blueAccent),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (timetable.id == timetableState.currentTimetableId)
                            const Icon(Icons.check_circle, color: Colors.green),
                          if (!timetable.isDefault)
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => timetableState.removeTimetable(timetable.id),
                            ),
                        ],
                      ),
                      onTap: () => timetableState.switchTimetable(timetable.id),
                    ),
                  );
                }),
                const Divider(height: 32),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: '新课表名称',
                    hintText: '输入名称如：大一上学期',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final name = textController.text.trim();
            if (name.isNotEmpty) {
              timetableState.addTimetable(Timetable(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
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
