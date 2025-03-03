// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/main.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';
import 'task_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  List<Task> filteredTasks = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskJson = prefs.getString('tasks');
    if (taskJson != null) {
      print('Loaded tasks: $taskJson'); // Debug print
      setState(() {
        tasks = (json.decode(taskJson) as List)
            .map((task) => Task.fromJson(task))
            .toList();
        filteredTasks = tasks;
        isLoading = false;
      });
    } else {
      print('No tasks found in SharedPreferences'); // Debug print
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskJson = json.encode(tasks);
    print('Saving tasks: $taskJson'); // Debug print
    prefs.setString('tasks', taskJson);
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
      filteredTasks = tasks;
      _saveTasks();
    });
  }

  void _editTask(int index, Task updatedTask) {
    setState(() {
      tasks[index] = updatedTask;
      filteredTasks = tasks;
      _saveTasks();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      filteredTasks = tasks;
      _saveTasks();
    });
  }

  void _filterTasks(String query) {
    setState(() {
      filteredTasks = tasks
          .where((task) =>
              task.title.toLowerCase().contains(query.toLowerCase()) ||
              task.description.toLowerCase().contains(query.toLowerCase()) ||
              task.subTasks.any((subTask) =>
                  subTask.title.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  void _toggleTaskStatus(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
      _saveTasks();
    });
  }

  void _toggleSubTaskStatus(int taskIndex, int subTaskIndex) {
    setState(() {
      tasks[taskIndex].subTasks[subTaskIndex].isCompleted =
          !tasks[taskIndex].subTasks[subTaskIndex].isCompleted;
      _saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.notes_rounded),
        title: const Text('Fine Todo App'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.skeleton,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _filterTasks(_searchController.text),
                ),
              ),
              onChanged: _filterTasks,
            ),
          ),
          Expanded(
            child: isLoading
                ? const SkeletonLoading()
                : filteredTasks.isEmpty
                    ? const Center(
                        child: Text('No tasks yet',
                            style:
                                TextStyle(color: AppColors.text, fontSize: 23)))
                    : ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return Dismissible(
                            key: Key(task.title),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: AppColors.error,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: AppColors.background,
                                size: 40,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Task'),
                                  content: const Text(
                                      'Are you sure you want to delete this task?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              _deleteTask(index);
                            },
                            child: Card(
                              color: _getTaskColor(index),
                              child: ExpansionTile(
                                leading: task.subTasks.isEmpty
                                    ? Checkbox(
                                        value: task.isCompleted,
                                        onChanged: (value) =>
                                            _toggleTaskStatus(index),
                                      )
                                    : Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            value: task.completionPercentage,
                                            backgroundColor:
                                                AppColors.background,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(AppColors.primary),
                                            strokeWidth: 5,
                                          ),
                                          Text(
                                            '${(task.completionPercentage * 100).toStringAsFixed(0)}%',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Text(
                                  task.description,
                                  style: TextStyle(
                                    color: AppColors.text,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: AppColors.text),
                                  onPressed: () =>
                                      _showEditTaskDialog(index, task),
                                ),
                                children: task.subTasks
                                    .map((subTask) => CheckboxListTile(
                                          title: Text(
                                            subTask.title,
                                            style: TextStyle(
                                              decoration: subTask.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                            ),
                                          ),
                                          value: subTask.isCompleted,
                                          onChanged: (value) =>
                                              _toggleSubTaskStatus(
                                            index,
                                            task.subTasks.indexWhere((st) =>
                                                st.title == subTask.title),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        child: const Icon(
          Icons.add_task_outlined,
          size: 35,
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDialog(
          onSave: _addTask,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showEditTaskDialog(int index, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDialog(
          task: task,
          onSave: (updatedTask) => _editTask(index, updatedTask),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Color _getTaskColor(int index) {
    final colors = [
      const Color(0xFFF8BBD0),
      const Color(0xFFC5CAE9),
      const Color(0xFFB2DFDB),
      const Color(0xFFFFCC80),
      const Color(0xFFCFD8DC),
    ];
    return colors[index % colors.length];
  }
}
