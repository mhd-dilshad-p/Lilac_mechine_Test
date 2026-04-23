import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  // Getters to filter tasks for the two UI sections
  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  TaskProvider() {
    _loadTasksFromPrefs(); 
  }

// add task logic 

  void addTask(String title) {
    if (title.trim().isEmpty) return;

    final newTask = Task(
      id: DateTime.now().toString(),
      title: title,
      isCompleted: false,
    );

    _tasks.insert(0, newTask); 
    _saveTasksToPrefs();     
    notifyListeners();         
  }


  void insertTaskAt(int index, Task task) {
    if (task.title.trim().isEmpty) return;
    final safeIndex = index.clamp(0, _tasks.length);
    _tasks.insert(safeIndex, task);
    _saveTasksToPrefs();
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      _saveTasksToPrefs();
      notifyListeners();
    }
  }

  void updateTask(String id, String newTitle) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].title = newTitle;
      _saveTasksToPrefs();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasksToPrefs();
    notifyListeners();
  }

  Task? removeTaskById(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    final removed = _tasks.removeAt(index);
    _saveTasksToPrefs();
    notifyListeners();
    return removed;
  }

  void clearCompleted() {
    _tasks.removeWhere((t) => t.isCompleted);
    _saveTasksToPrefs();
    notifyListeners();
  }

  void deleteAll() {
    _tasks.clear();
    _saveTasksToPrefs();
    notifyListeners();
  }

  Future<void> _saveTasksToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = json.encode(_tasks.map((t) => t.toMap()).toList());
    await prefs.setString('user_tasks', data);
  }

  Future<void> _loadTasksFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('user_tasks');
    if (data != null) {
      final List<dynamic> decoded = json.decode(data);
      _tasks = decoded.map((item) => Task.fromMap(item)).toList();
      notifyListeners();
    }
  }
}