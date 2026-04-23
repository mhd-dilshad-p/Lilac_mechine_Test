import 'package:flutter/material.dart';
import 'package:lilac_mechine_test/provider/task_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/task_input_field.dart';
import '../widgets/task_tile.dart';
import '../models/task_model.dart';
import 'package:lilac_mechine_test/provider/theme_provider.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final GlobalKey<AnimatedListState> _pendingListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _completedListKey = GlobalKey<AnimatedListState>();

  late List<Task> _pending;
  late List<Task> _completed;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TaskProvider>();
    _pending = List<Task>.from(provider.pendingTasks);
    _completed = List<Task>.from(provider.completedTasks);
  }

  void _addTaskAnimated(String title) {
    final task = Task(id: DateTime.now().toString(), title: title, isCompleted: false);
    _pending.insert(0, task);
    _pendingListKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
    context.read<TaskProvider>().insertTaskAt(0, task);
  }

  void _removeTaskAnimated(Task task) {
    final provider = context.read<TaskProvider>();
    int idx = _pending.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      final removed = _pending.removeAt(idx);
      _pendingListKey.currentState?.removeItem(
        idx,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          axisAlignment: 0.0,
          child: TaskTile(task: removed),
        ),
        duration: const Duration(milliseconds: 300),
      );
      provider.deleteTask(task.id);
      return;
    }

    idx = _completed.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      final removed = _completed.removeAt(idx);
      _completedListKey.currentState?.removeItem(
        idx,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          axisAlignment: 0.0,
          child: TaskTile(task: removed),
        ),
        duration: const Duration(milliseconds: 300),
      );
      provider.deleteTask(task.id);
    }
  }

  void _toggleTaskAnimated(Task task) {
    final provider = context.read<TaskProvider>();
    if (!task.isCompleted) {
      final idx = _pending.indexWhere((t) => t.id == task.id);
      if (idx == -1) return;
      final removed = _pending.removeAt(idx);
      _pendingListKey.currentState?.removeItem(
        idx,
        (context, animation) => FadeTransition(
          opacity: animation,
          child: TaskTile(task: removed),
        ),
        duration: const Duration(milliseconds: 250),
      );

      final newTask = Task(id: removed.id, title: removed.title, isCompleted: true);
      _completed.insert(0, newTask);
      _completedListKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));

      provider.toggleTaskStatus(task.id);
    } else {
      final idx = _completed.indexWhere((t) => t.id == task.id);
      if (idx == -1) return;
      final removed = _completed.removeAt(idx);
      _completedListKey.currentState?.removeItem(
        idx,
        (context, animation) => FadeTransition(
          opacity: animation,
          child: TaskTile(task: removed),
        ),
        duration: const Duration(milliseconds: 250),
      );

      final newTask = Task(id: removed.id, title: removed.title, isCompleted: false);
      _pending.insert(0, newTask);
      _pendingListKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));

      provider.toggleTaskStatus(task.id);
    }
  }

  void _editTask(Task task, String newTitle) {
    context.read<TaskProvider>().updateTask(task.id, newTitle);
    // update local lists
    final pIdx = _pending.indexWhere((t) => t.id == task.id);
    if (pIdx != -1) _pending[pIdx].title = newTitle;
    final cIdx = _completed.indexWhere((t) => t.id == task.id);
    if (cIdx != -1) _completed[cIdx].title = newTitle;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("To-Do List", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        actions: [

          Builder(builder: (ctx) {
            final themeProv = ctx.watch<ThemeProvider>();
            return IconButton(
              tooltip: themeProv.isDark ? 'Switch to light' : 'Switch to dark',
              icon: Icon(themeProv.isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => ctx.read<ThemeProvider>().toggle(),
            );
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaskInputField(onAdd: _addTaskAnimated),
              const SizedBox(height: 20),
              Expanded(
                child: isWide
                    ? Row(
                        children: [
                          Expanded(child: _buildPendingSection()),
                          const SizedBox(width: 20),
                          Expanded(child: _buildCompletedSection()),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPendingHeader(),
                          Expanded(child: _buildPendingList()),
                          const Divider(),
                          _buildCompletedHeader(),
                          Expanded(child: _buildCompletedList()),
                        ],
                      ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final kept = _completed.length;
                        for (var i = kept - 1; i >= 0; i--) {
                          _completedListKey.currentState?.removeItem(
                            i,
                            (context, animation) => SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: 0.0,
                              child: TaskTile(task: _completed[i]),
                            ),
                            duration: const Duration(milliseconds: 200),
                          );
                        }
                        _completed.clear();
                        provider.clearCompleted();
                      },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text("Clear Completed"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final totalPending = _pending.length;
                        for (var i = totalPending - 1; i >= 0; i--) {
                          _pendingListKey.currentState?.removeItem(
                            i,
                            (context, animation) => SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: 0.0,
                              child: TaskTile(task: _pending[i]),
                            ),
                            duration: const Duration(milliseconds: 200),
                          );
                        }
                        _pending.clear();

                        final totalCompleted = _completed.length;
                        for (var i = totalCompleted - 1; i >= 0; i--) {
                          _completedListKey.currentState?.removeItem(
                            i,
                            (context, animation) => SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: 0.0,
                              child: TaskTile(task: _completed[i]),
                            ),
                            duration: const Duration(milliseconds: 200),
                          );
                        }
                        _completed.clear();
                        provider.deleteAll();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Delete All"),
                    ),
                  ),
                ],
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPendingHeader() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 6.0),
        child: Text("Pending Tasks", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _buildCompletedHeader() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 6.0),
        child: Text("Completed", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _buildPendingList() => AnimatedList(
        key: _pendingListKey,
        initialItemCount: _pending.length,
        itemBuilder: (ctx, i, animation) {
          final task = _pending[i];
          return SizeTransition(
            sizeFactor: animation,
            axisAlignment: 0.0,
            child: Dismissible(
              key: ValueKey(task.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => _removeTaskAnimated(task),
              child: TaskTile(
                task: task,
                onDelete: _removeTaskAnimated,
                onToggle: _toggleTaskAnimated,
                onEdit: _editTask,
              ),
            ),
          );
        },
      );

  Widget _buildCompletedList() => AnimatedList(
        key: _completedListKey,
        initialItemCount: _completed.length,
        itemBuilder: (ctx, i, animation) {
          final task = _completed[i];
          return SizeTransition(
            sizeFactor: animation,
            axisAlignment: 0.0,
            child: Dismissible(
              key: ValueKey(task.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => _removeTaskAnimated(task),
              child: TaskTile(
                task: task,
                onDelete: _removeTaskAnimated,
                onToggle: _toggleTaskAnimated,
                onEdit: _editTask,
              ),
            ),
          );
        },
      );

  Widget _buildPendingSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPendingHeader(),
          Expanded(child: _buildPendingList()),
        ],
      );

  Widget _buildCompletedSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompletedHeader(),
          Expanded(child: _buildCompletedList()),
        ],
      );
}