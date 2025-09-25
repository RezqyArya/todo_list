import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: const MyApp(),
    ),
  );
}

class Todo {
  String title;
  bool isDone;
  Todo({
    required this.title,
    this.isDone = false,
  });
}

class TodoProvider extends ChangeNotifier {
  final List<Todo> _todos = [];
  String _filter = 'All';

  List<Todo> get todos {
    if (_filter == 'Active') {
      return _todos.where((t) => !t.isDone).toList();
    } else if (_filter == 'Done') {
      return _todos.where((t) => t.isDone).toList();
    }
    return _todos;
  }

  String get filter => _filter;

  void addTodo(String title) {
    if (title.trim().length < 3) return;
    _todos.add(Todo(title: title.trim()));
    notifyListeners();
  }

  void toggleDone(int index) {
    _todos[index].isDone = !_todos[index].isDone;
    notifyListeners();
  }

  void remove(int index) {
    _todos.removeAt(index);
    notifyListeners();
  }

  void setFilter(String f) {
    _filter = f;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do Mini',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do Mini"),
        actions: [
          PopupMenuButton<String>(
            initialValue: provider.filter,
            onSelected: (val) => provider.setFilter(val),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'Active', child: Text('Active')),
              PopupMenuItem(value: 'Done', child: Text('Done')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: "Tambah tugas",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    provider.addTodo(_controller.text);
                    _controller.clear();
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: provider.todos.length,
              itemBuilder: (context, index) {
                final todo = provider.todos[index];
                return ListTile(
                  leading: Checkbox(
                    value: todo.isDone,
                    onChanged: (_) => provider.toggleDone(index),
                  ),
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration:
                          todo.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => provider.remove(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}