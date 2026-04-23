import 'package:flutter/material.dart';
import 'package:lilac_mechine_test/provider/task_provider.dart';
import 'package:provider/provider.dart';


class TaskInputField extends StatefulWidget {
  final void Function(String)? onAdd;

  const TaskInputField({super.key, this.onAdd});

  @override
  State<TaskInputField> createState() => _TaskInputFieldState();
}

class _TaskInputFieldState extends State<TaskInputField> {
  final TextEditingController _controller = TextEditingController();

  void _submitAction() {
    final String text = _controller.text.trim();

    if (text.isNotEmpty) {
      if (widget.onAdd != null) {
        widget.onAdd!(text);
      } else {
        context.read<TaskProvider>().addTask(text);
      }
      
      _controller.clear();
      
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a task name")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Enter new task",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            onSubmitted: (_) => _submitAction(), 
          ),
        ),
        const SizedBox(width: 12),
        
       
        Material(
          color: Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _submitAction,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}