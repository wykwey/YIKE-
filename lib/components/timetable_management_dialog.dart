import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/timetable_state.dart';
import '../data/timetable.dart';

class TimetableManagementDialog extends StatefulWidget {
  const TimetableManagementDialog({super.key});

  @override
  State<TimetableManagementDialog> createState() => _TimetableManagementDialogState();
}

class _TimetableManagementDialogState extends State<TimetableManagementDialog> {
  String? editingId;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

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
                  final isCurrent = timetable.id == timetableState.currentTimetableId;
                  _controllers.putIfAbsent(timetable.id, () => TextEditingController(text: timetable.name));
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrent ? Colors.blue.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: isCurrent && editingId == timetable.id
                          ? TextField(
                              controller: _controllers[timetable.id],
                              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              autofocus: true,
                              onSubmitted: (value) {
                                final newName = value.trim();
                                if (newName.isNotEmpty && newName != timetable.name) {
                                  timetableState.updateTimetable(timetable.copyWith(name: newName));
                                }
                                setState(() { editingId = null; });
                              },
                              onEditingComplete: () {
                                final newName = _controllers[timetable.id]!.text.trim();
                                if (newName.isNotEmpty && newName != timetable.name) {
                                  timetableState.updateTimetable(timetable.copyWith(name: newName));
                                }
                                setState(() { editingId = null; });
                              },
                            )
                          : Text(
                              timetable.name,
                              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                      leading: const Icon(Icons.calendar_today_outlined, color: Colors.blueAccent),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCurrent)
                            ...[
                              const Icon(Icons.check_circle, color: Colors.green, size: 20),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                tooltip: '重命名',
                                onPressed: () {
                                  setState(() { editingId = timetable.id; });
                                },
                              ),
                            ],
                          if (!isCurrent)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
