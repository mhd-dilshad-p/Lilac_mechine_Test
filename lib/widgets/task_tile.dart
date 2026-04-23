import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final void Function(Task)? onDelete;
  final void Function(Task)? onToggle;
  final void Function(Task, String)? onEdit;

  const TaskTile({super.key, required this.task, this.onDelete, this.onToggle, this.onEdit});

  void _showEditDialog(BuildContext context) {
    final editController = TextEditingController(text: task.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Task"),
        content: TextField(controller: editController, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (onEdit != null) onEdit!(task, editController.text);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(task.id),
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      leading: Semantics(
        label: task.isCompleted ? 'Completed' : 'Pending',
        child: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle != null ? onToggle!(task) : null,
        ),
      ),
      title: Text(
        task.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? Colors.grey : null,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!task.isCompleted)
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showEditDialog(context),
            ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => onDelete != null ? onDelete!(task) : null,
          ),
        ],
      ),
    );
  }
}