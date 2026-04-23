import 'package:flutter/material.dart';
import 'package:lilac_mechine_test/provider/task_provider.dart';
import 'package:lilac_mechine_test/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'screens/todo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Builder(builder: (context) {
        final themeProvider = context.watch<ThemeProvider>();
        return MaterialApp(
          title: 'Lilac To-Do App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D3142)),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2D3142),
              brightness: Brightness.dark,
            ),
          ),
          themeMode: themeProvider.mode,
          home: const TodoScreen(),
        );
      }),
    );
  }
}