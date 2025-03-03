class SubTask {
  String title;
  bool isCompleted;

  SubTask({required this.title, this.isCompleted = false});

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        title: json['title'],
        isCompleted: json['isCompleted'] ?? false, // Default to false if null
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'isCompleted': isCompleted,
      };
}

class Task {
  String title;
  String description;
  bool isCompleted;
  List<SubTask> subTasks;

  Task({
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.subTasks = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        description:
            json['description'] ?? '', // Default to empty string if null
        isCompleted: json['isCompleted'] ?? false, // Default to false if null
        subTasks: (json['subTasks'] as List?)
                ?.map((subTask) => SubTask.fromJson(subTask))
                .toList() ??
            [], // Default to empty list if null
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'subTasks': subTasks.map((subTask) => subTask.toJson()).toList(),
      };

  double get completionPercentage {
    if (subTasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completedSubTasks =
        subTasks.where((subTask) => subTask.isCompleted).length;
    return completedSubTasks / subTasks.length;
  }
}
