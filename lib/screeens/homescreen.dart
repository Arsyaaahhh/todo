import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/task.dart';
import 'package:todo/screeens/Add_task.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  DateTime selectedDate = DateTime.now();

  final List<Task> tasks = [
    Task(title: "data"),
    Task(title: "Finish"),
    Task(title: "hang"),
  ];

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks
        .map(
          (task) => {
            "title": task.title,
            "isDone": task.isDone,
            "dueDate": task.dueDate.toIso8601String(),
          },
        )
        .toList();
    prefs.setString("tasks", jsonEncode(tasksJson));
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString("tasks");
    if (tasksString != null) {
      final List<dynamic> tasksJson = jsonDecode(tasksString);
      setState(() {
        tasks.clear();
        tasks.addAll(
          tasksJson.map(
            (json) => Task(
              title: json["title"],
              isDone: json["isDone"],
              dueDate: json["dueDate"] != null
                  ? DateTime.parse(json["dueDate"])
                  : DateTime.now(),
            ),
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    // Filter tasks by selected date
    final filteredTasks = tasks
        .where(
          (task) =>
              task.dueDate.year == selectedDate.year &&
              task.dueDate.month == selectedDate.month &&
              task.dueDate.day == selectedDate.day,
        )
        .toList();

    // Calculate statistics for selected date
    final totalTasks = filteredTasks.where((task) => !task.isDone).length;
    final completedTasks = filteredTasks.where((task) => task.isDone).length;

    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: Column(
        children: [
          // Date and Summary Section
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                // Summary Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard(
                      label: "Total Task",
                      value: "$totalTasks",
                      icon: Icons.assignment,
                      backgroundColor: const Color.fromARGB(255, 136, 11, 2),
                    ),
                    SizedBox(width: 16),
                    _buildSummaryCard(
                      label: "Completed",
                      value: "$completedTasks",
                      icon: Icons.check_circle,
                      backgroundColor: const Color.fromARGB(255, 64, 154, 67),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tasks List
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Text(
                      "No tasks for this date",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Dismissible(
                        key: Key(task.title),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.delete, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Delete",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            tasks.removeWhere((t) => t.title == task.title);
                          });
                          saveTasks();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Task Deleted")),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: GestureDetector(
                              onTap: () {
                                setState(() {
                                  task.isDone = !task.isDone;
                                });
                                saveTasks();
                              },
                              child: Icon(
                                task.isDone
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: task.isDone ? Colors.green : Colors.grey,
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            onTap: () async {
                              final editedTaskTitle =
                                  await Navigator.push<String>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return AddTask(
                                          existingTitle: task.title,
                                        );
                                      },
                                    ),
                                  );

                              if (editedTaskTitle != null &&
                                  editedTaskTitle.isNotEmpty) {
                                setState(() {
                                  task.title = editedTaskTitle;
                                });
                                saveTasks();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTaskTitle = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddTask();
              },
            ),
          );

          if (newTaskTitle != null && newTaskTitle.isNotEmpty) {
            setState(() {
              tasks.add(Task(title: newTaskTitle, dueDate: selectedDate));
            });
            saveTasks();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(80),
      child: Container(
        color: Colors.deepPurple[900],
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.subtract(Duration(days: 1));
                    });
                  },
                ),
                Text(
                  _formatDate(selectedDate),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.add(Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color? backgroundColor,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
