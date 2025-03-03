import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import '../utils/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 15), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          color: AppColors.primary,
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.7,
        ),
      ),
    );
  }
}

class SkeletonLoading extends StatelessWidget {
  const SkeletonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => ListTile(
        title: Container(
          height: 20,
          color: AppColors.skeleton,
        ),
        subtitle: Container(
          height: 15,
          color: AppColors.skeleton,
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import 'dart:convert';

// void main() {
//   tz.initializeTimeZones();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Task Manager',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: AppColors.background,
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }

// // Splash Screen
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const HomeScreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       body: Center(
//         child: Icon(
//           Icons.task,
//           size: 100,
//           color: AppColors.secondary,
//         ),
//       ),
//     );
//   }
// }

// // Home Screen
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   List<Task> tasks = [];
//   List<Task> filteredTasks = [];
//   bool isLoading = true;
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadTasks();
//     _scheduleNotification();
//   }

//   Future<void> _loadTasks() async {
//     final prefs = await SharedPreferences.getInstance();
//     final taskJson = prefs.getString('tasks');
//     if (taskJson != null) {
//       setState(() {
//         tasks = (json.decode(taskJson) as List)
//             .map((task) => Task.fromJson(task))
//             .toList();
//         filteredTasks = tasks;
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _saveTasks() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString('tasks', json.encode(tasks));
//   }

//   Future<void> _scheduleNotification() async {
//     final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: androidSettings);
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);

//     final now = DateTime.now().toUtc();
//     final notificationTime = tz.TZDateTime.from(
//       DateTime.utc(
//           now.year, now.month, now.day, 20, 30), // 30 mins before 21:00 UTC
//       tz.local,
//     );

//     if (now.isBefore(notificationTime)) {
//       await flutterLocalNotificationsPlugin.zonedSchedule(
//         0,
//         'Task Reminder',
//         'You have tasks due soon!',
//         notificationTime,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'task_channel',
//             'Task Reminders',
//             importance: Importance.high,
//           ),
//         ),
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         payload: 'task_reminder',
//       );
//     }
//   }

//   void _addTask(Task task) {
//     setState(() {
//       tasks.add(task);
//       filteredTasks = tasks;
//       _saveTasks();
//     });
//   }

//   void _editTask(int index, Task updatedTask) {
//     setState(() {
//       tasks[index] = updatedTask;
//       filteredTasks = tasks;
//       _saveTasks();
//     });
//   }

//   void _deleteTask(int index) {
//     setState(() {
//       tasks.removeAt(index);
//       filteredTasks = tasks;
//       _saveTasks();
//     });
//   }

//   void _filterTasks(String query) {
//     setState(() {
//       filteredTasks = tasks
//           .where((task) =>
//               task.title.toLowerCase().contains(query.toLowerCase()) ||
//               task.description.toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   void _toggleTaskStatus(int index) {
//     setState(() {
//       tasks[index].status = tasks[index].status == TaskStatus.completed
//           ? TaskStatus.incomplete
//           : TaskStatus.completed;
//       _saveTasks();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: Icon(Icons.notes_rounded),
//         title: const Text('Task Manager'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.skeleton,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 labelText: 'Search',
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: () => _filterTasks(_searchController.text),
//                 ),
//               ),
//               onChanged: _filterTasks,
//             ),
//           ),
//           Expanded(
//             child: isLoading
//                 ? const SkeletonLoading()
//                 : filteredTasks.isEmpty
//                     ? const Center(
//                         child: Text('No tasks yet',
//                             style:
//                                 TextStyle(color: AppColors.text, fontSize: 23)))
//                     : ListView.builder(
//                         itemCount: filteredTasks.length,
//                         itemBuilder: (context, index) {
//                           final task = filteredTasks[index];
//                           return Dismissible(
//                             key: Key(task.title),
//                             onDismissed: (direction) => _deleteTask(index),
//                             background: Container(
//                               padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
//                               color: AppColors.error,
//                               child: Icon(
//                                 Icons.delete_outline,
//                                 size: 40,
//                                 color: AppColors.background,
//                               ),
//                             ),
//                             confirmDismiss: (direction) async {
//                               return await showDialog(
//                                 context: context,
//                                 builder: (context) => AlertDialog(
//                                   title: const Text('Delete Task'),
//                                   content: const Text(
//                                       'Are you sure you want to delete this task?'),
//                                   actions: [
//                                     TextButton(
//                                       onPressed: () =>
//                                           Navigator.pop(context, false),
//                                       child: const Text('Cancel'),
//                                     ),
//                                     TextButton(
//                                       onPressed: () =>
//                                           Navigator.pop(context, true),
//                                       child: const Text('Delete'),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                             child: Card(
//                               color: _getTaskColor(index),
//                               child: ListTile(
//                                 leading: Transform.scale(
//                                   scale: 1.5,
//                                   child: Checkbox(
//                                     checkColor: _getTaskColor(index),
//                                     value: task.status == TaskStatus.completed,
//                                     onChanged: (value) =>
//                                         _toggleTaskStatus(index),
//                                   ),
//                                 ),
//                                 title: Text(task.title,
//                                     style: TextStyle(
//                                         color: AppColors.text,
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold)),
//                                 subtitle: Text(task.description,
//                                     style: TextStyle(color: AppColors.text)),
//                                 trailing: IconButton(
//                                   icon: const Icon(Icons.edit,
//                                       color: AppColors.text),
//                                   onPressed: () =>
//                                       _showEditTaskDialog(index, task),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showAddTaskDialog(),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.background,
//         child: const Icon(
//           Icons.add_task_outlined,
//           size: 35,
//         ),
//       ),
//     );
//   }

//   void _showAddTaskDialog() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TaskDialog(
//           onSave: _addTask,
//         ),
//         fullscreenDialog: true,
//       ),
//     );
//   }

//   void _showEditTaskDialog(int index, Task task) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TaskDialog(
//           task: task,
//           onSave: (updatedTask) => _editTask(index, updatedTask),
//         ),
//         fullscreenDialog: true,
//       ),
//     );
//   }

//   Color _getTaskColor(int index) {
//     final colors = [
//       const Color(0xFFF8BBD0),
//       const Color(0xFFC5CAE9),
//       const Color(0xFFB2DFDB),
//       const Color(0xFFFFCC80),
//       const Color(0xFFCFD8DC),
//     ];
//     return colors[index % colors.length];
//   }
// }

// // Task Dialog
// class TaskDialog extends StatefulWidget {
//   final Task? task;
//   final Function(Task) onSave;

//   const TaskDialog({super.key, this.task, required this.onSave});

//   @override
//   State<TaskDialog> createState() => _TaskDialogState();
// }

// class _TaskDialogState extends State<TaskDialog> {
//   final _formKey = GlobalKey<FormState>();
//   late String _title;
//   late String _description;
//   late DateTime _dueDate;
//   late TimeOfDay _time;

//   @override
//   void initState() {
//     super.initState();
//     _title = widget.task?.title ?? '';
//     _description = widget.task?.description ?? '';
//     _dueDate = widget.task?.dueDate ?? DateTime.now();
//     _time = widget.task != null
//         ? TimeOfDay.fromDateTime(widget.task!.time)
//         : TimeOfDay.now();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _dueDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//     if (pickedDate != null) {
//       setState(() {
//         _dueDate = pickedDate;
//       });
//     }
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final pickedTime = await showTimePicker(
//       context: context,
//       initialTime: _time,
//     );
//     if (pickedTime != null) {
//       setState(() {
//         _time = pickedTime;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.skeleton,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: () {
//               if (_formKey.currentState!.validate()) {
//                 _formKey.currentState!.save();
//                 widget.onSave(Task(
//                   title: _title,
//                   description: _description,
//                   dueDate: _dueDate,
//                   time: DateTime(
//                     _dueDate.year,
//                     _dueDate.month,
//                     _dueDate.day,
//                     _time.hour,
//                     _time.minute,
//                   ),
//                 ));
//                 Navigator.pop(context);
//               }
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 initialValue: _title,
//                 decoration: const InputDecoration(labelText: 'Title'),
//                 onSaved: (value) => _title = value!,
//                 validator: (value) =>
//                     value!.isEmpty ? 'Title is required' : null,
//               ),
//               TextFormField(
//                 initialValue: _description,
//                 decoration: const InputDecoration(labelText: 'Description'),
//                 onSaved: (value) => _description = value!,
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Text('Due Date: ${DateFormat.yMd().format(_dueDate)}'),
//                   const SizedBox(width: 10),
//                   ElevatedButton(
//                     onPressed: () => _selectDate(context),
//                     child: const Text('Select Date'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Text('Time: ${_time.format(context)}'),
//                   const SizedBox(width: 10),
//                   ElevatedButton(
//                     onPressed: () => _selectTime(context),
//                     child: const Text('Select Time'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Skeleton Loading
// class SkeletonLoading extends StatelessWidget {
//   const SkeletonLoading({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: 5,
//       itemBuilder: (context, index) => ListTile(
//         title: Container(
//           height: 20,
//           color: AppColors.skeleton,
//         ),
//         subtitle: Container(
//           height: 15,
//           color: AppColors.skeleton,
//         ),
//       ),
//     );
//   }
// }

// // App Colors
// class AppColors {
//   static const primary = Color(0xFF1755d0);
//   static const secondary = Color(0xFFfce43e);
//   static const background = Color(0xFFd3e2ee);
//   static const text = Color(0xFF000000);
//   static const error = Color(0xFFE00041);
//   static const skeleton = Color(0xFFE0E0E0);
// }

// // Task Model
// enum TaskStatus { completed, incomplete }

// class Task {
//   String title;
//   String description;
//   DateTime dueDate;
//   DateTime time;
//   TaskStatus status;

//   Task({
//     required this.title,
//     this.description = '',
//     DateTime? dueDate,
//     DateTime? time,
//     this.status = TaskStatus.incomplete,
//   })  : dueDate = dueDate ?? DateTime.now(),
//         time = time ?? DateTime.now().add(const Duration(minutes: 5));

//   factory Task.fromJson(Map<String, dynamic> json) => Task(
//         title: json['title'],
//         description: json['description'],
//         dueDate: DateTime.parse(json['dueDate']),
//         time: DateTime.parse(json['time']),
//         status: TaskStatus.values[json['status']],
//       );

//   Map<String, dynamic> toJson() => {
//         'title': title,
//         'description': description,
//         'dueDate': dueDate.toIso8601String(),
//         'time': time.toIso8601String(),
//         'status': status.index,
//       };
// }



// // [
// //     {"id": 1, "name": "Clean My Room"},
// //     {"id": 2, "name": "Do the Laundry"},
// //     {"id": 3, "name": "Grocery Shopping"},
// //     {"id": 4, "name": "Prepare Dinner"},
// //     {"id": 5, "name": "Complete Homework"},
// //     {"id": 6, "name": "Walk the Dog"},
// //     {"id": 7, "name": "Organize the Garage"},
// //     {"id": 8, "name": "Read a Book"},
// //     {"id": 9, "name": "Exercise for 30 Minutes"},
// //     {"id": 10, "name": "Call Mom"},
// //     {"id": 11, "name": "Attend Yoga Class"},
// //     {"id": 12, "name": "Finish Reading Novel"},
// //     {"id": 13, "name": "Prepare Presentation"},
// //     {"id": 14, "name": "Go for a Run"},
// //     {"id": 15, "name": "Visit the Dentist"},
// //     {"id": 16, "name": "Clean the Kitchen"},
// //     {"id": 17, "name": "Water the Plants"},
// //     {"id": 18, "name": "Organize Files"},
// //     {"id": 19, "name": "Schedule Doctor Appointment"},
// //     {"id": 20, "name": "Plan Weekend Trip"}
// // ]