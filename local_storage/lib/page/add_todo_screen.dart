import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/todo.dart';

class AddTodoScreen extends StatefulWidget {
  final int? index; //tambahkan ini
  final Todo? todo; //tambahkan ini
  const AddTodoScreen({super.key, this.index, this.todo});
  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  //tambahkan 3 variabel dibawah ini
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  late bool _isEditMode;

  @override
  void initState() {
    _isEditMode = widget.index != null && widget.todo != null;
    super.initState();
    if (_isEditMode) {
      titleController.text = widget.todo!.title;
      subtitleController.text = widget.todo!.subtitle;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Todo' : 'Add Todo',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Subtitle',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final box = Hive.box<Todo>('todos');
                final newTodo = Todo(
                  title: titleController.text,
                  subtitle: subtitleController.text,
                );
                if (_isEditMode) {
                  box.putAt(widget.index!, newTodo);
                } else {
                  box.add(newTodo);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(_isEditMode ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}
// kode sisanya
