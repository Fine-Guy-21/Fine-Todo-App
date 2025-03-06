import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;

  const TaskDialog({super.key, this.task, required this.onSave});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  final List<SubTask> _subTasks = [];
  final List<TextEditingController> _subTaskControllers = [];

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _subTasks.addAll(widget.task?.subTasks ?? []);
    _subTasks.forEach((subTask) {
      _subTaskControllers.add(TextEditingController(text: subTask.title));
    });
  }

  void _addSubTask() {
    // Check if the last subtask field is empty
    if (_subTaskControllers.isNotEmpty &&
        _subTaskControllers.last.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill the previous subtask field')),
      );
      return;
    }

    setState(() {
      _subTaskControllers.add(TextEditingController());
      _subTasks.add(SubTask(title: ''));
    });
  }

  void _removeSubTask(int index) {
    setState(() {
      _subTaskControllers.removeAt(index);
      _subTasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
      elevation: 10, // Shadow depth

      insetPadding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.task == null ? 'Add Task' : 'Edit Task',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: _title,
                      decoration: const InputDecoration(labelText: 'Title'),
                      onSaved: (value) => _title = value!,
                      validator: (value) =>
                          value!.isEmpty ? 'Title is required' : null,
                    ),
                    TextFormField(
                      initialValue: _description,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      onSaved: (value) => _description = value!,
                    ),
                    const SizedBox(height: 20),
                    const Text('Subtasks',
                        style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.underline)),
                    ..._subTaskControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      TextEditingController controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText: 'Subtask ${index + 1}',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => _removeSubTask(index),
                                  ),
                                ),
                                onChanged: (value) {
                                  _subTasks[index].title = value;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Subtask is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    TextButton(
                      onPressed: _addSubTask,
                      child: const Text('Add Subtask'),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            widget.onSave(Task(
                              title: _title,
                              description: _description,
                              subTasks: _subTasks,
                            ));
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.save,
                              color: AppColors.background,
                            ),
                            const SizedBox(width: 10),
                            const Text('Save'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close,
                  color: AppColors.primary), // Close icon
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
          ),
        ],
      ),
    );
  }
}
