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

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _subTasks.addAll(widget.task?.subTasks ?? []);
  }

  void _addSubTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextFormField(
          decoration: const InputDecoration(labelText: 'Subtask Title'),
          onFieldSubmitted: (value) {
            setState(() {
              _subTasks.add(SubTask(title: value));
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.skeleton,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (value) => _title = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Title is required' : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 20),
              const Text('Subtasks', style: TextStyle(fontSize: 18)),
              ..._subTasks.map((subTask) => ListTile(
                    title: Text(subTask.title),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _subTasks.remove(subTask);
                        });
                      },
                    ),
                  )),
              TextButton(
                onPressed: _addSubTask,
                child: const Text('Add Subtask'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
