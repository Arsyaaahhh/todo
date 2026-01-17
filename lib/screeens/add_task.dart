import 'package:flutter/material.dart';

class AddTask extends StatefulWidget {
  final String? existingTitle;
  const AddTask({super.key, this.existingTitle});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existingTitle ?? "");
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add new data")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "Task title")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {
              final tasktitle = _controller.text;
              if (tasktitle.isNotEmpty) {
                Navigator.pop(context, tasktitle);
              }
            }, child: Text("Save")),
          ],
        ),
      ),
    );
  }
}
