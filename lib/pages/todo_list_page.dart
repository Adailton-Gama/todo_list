import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/repository/todo_repository.dart';
import 'package:todo_list/widgtes/item_todo_list.dart';
import 'package:vibration/vibration.dart';

import '../models/todo.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController task = TextEditingController();
  final TextEditingController editText = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];
  int count = 0;
  Todo? offDelete;
  int? offDeletePos;
  int pendente = 0;
  int completos = 0;

  @override
  void initState() {
    super.initState();
    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
        count = todos.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                const Text(
                  'Tarefas',
                  style: TextStyle(fontSize: 40),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: task,
                        onSubmitted: addTaskSubmited,
                        decoration: const InputDecoration(
                          //labelText: 'Tarefa',
                          hintText: 'Adicione uma tarefa',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(18),
                        primary: Color.fromRGBO(0x12, 0xCB, 0xE0, 1),
                      ),
                      onPressed: addTask,
                      child: const Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        ItemTodoList(
                          todo: todo,
                          onDelete: onDelete,
                          onUpdate: onUpdate,
                          onComplete: onComplete,
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Você possui um total de:  $count tarefas'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(0x12, 0xCB, 0xE0, 1),
                        padding: const EdgeInsets.all(18),
                      ),
                      onPressed: clearList,
                      child: const Text(
                        'Limpar Lista',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addTask() {
    String getTask = task.text;
    if (getTask == '') {
      print('Nenhuma tarefa adicionada');
      Vibration.vibrate();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Favor preencher a tarefa',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color.fromRGBO(0x12, 0xCB, 0xE0, 1),
        ),
      );
    } else {
      print('Tarefa $getTask adicionada!');
      setState(() {
        Todo newTodo = Todo(
          title: getTask,
          dataTime: DateTime.now(),
          complete: false,
        );
        todos.add(newTodo);
        count = todos.length;
        print('indice: $count, da tarefa: $getTask');
        todoRepository.saveTodoList(todos);
      });
      task.clear();
    }
  }

  void addTaskSubmited(String getTask) {
    String getTask = task.text;
    if (getTask == '') {
      print('Nenhuma tarefa adicionada');
      Vibration.vibrate();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Favor preencher a tarefa!',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color.fromRGBO(0x12, 0xCB, 0xE0, 1),
      ));
    } else {
      print('Tarefa $getTask adicionada!');
      setState(() {
        Todo newTodo =
            Todo(title: task.text, dataTime: DateTime.now(), complete: false);
        todos.add(newTodo);
        count = todos.length;
        print('indice: $count, da tarefa: $getTask');
        todoRepository.saveTodoList(todos);
      });
      task.clear();
    }
  }

  void clearList() {
    List<Todo> backupTodo = todos;
    setState(() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Limpar Tarefas'),
                content: Text('Deseja realmente apagar todos as tarefas?'),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red[400],
                    ),
                    onPressed: () {
                      setState(() {
                        todos.clear();
                        count = todos.length;
                        todoRepository.saveTodoList(todos);
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Sim'),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(0x12, 0xCB, 0xE0, 1),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Não')),
                ],
              ));
    });
    task.clear();
  }

  void onDelete(Todo todo) {
    offDelete = todo;
    offDeletePos = todos.indexOf(todo);
    setState(() {
      todos.remove(todo);
      count = todos.length;
      todoRepository.saveTodoList(todos);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey[300],
        content: Text(
          'A tarefa ${todo.title} foi removida com sucesso!',
          style: const TextStyle(color: Colors.black),
        ),
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: Color.fromRGBO(0x12, 0xCB, 0xE0, 1),
          onPressed: () {
            setState(() {
              todos.insert(offDeletePos!, offDelete!);
              todoRepository.saveTodoList(todos);
            });
          },
        ),
      ),
    );
  }

  void onUpdate(Todo todo) {
    setState(() {
      print(todo.title);
    });
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Editar'),
            content: TextField(
                controller: editText,
                decoration: const InputDecoration(
                  hintText: 'Digite a nova tarefa',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (String text) {
                  setState(
                    () {
                      if (editText.text == '') {
                        Vibration.vibrate();
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor:
                                Color.fromRGBO(0x12, 0xCB, 0xE0, 1),
                            content: Text(
                                'Favor preencher a tarefa que deseja alterar!'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      } else {
                        todo.title = editText.text;
                        todo.dataTime = DateTime.now();
                        editText.clear();
                        todoRepository.saveTodoList(todos);
                        Navigator.pop(context);
                      }
                    },
                  );
                }),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(0x12, 0xCB, 0xE0, 1),
                  ),
                  onPressed: () {
                    setState(() {
                      if (editText.text == '') {
                        Vibration.vibrate();
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor:
                                Color.fromRGBO(0x12, 0xCB, 0xE0, 1),
                            content: Text(
                                'Favor preencher a tarefa que deseja alterar!'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      } else {
                        todo.title = editText.text;
                        todo.dataTime = DateTime.now();
                        editText.clear();
                        todoRepository.saveTodoList(todos);
                        Navigator.pop(context);
                      }
                    });
                  },
                  child: Text('Editar')),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red[400]),
                  onPressed: () {
                    editText.clear();
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar'))
            ],
          );
        });
  }

  void onComplete(Todo todo) {
    bool oncomplete = false;
    setState(() {
      if (todo.complete == true) {
        todo.complete = false;
        oncomplete = false;
      } else {
        todo.complete = true;
        oncomplete = false;
      }
      ;
      todoRepository.saveTodoList(todos);
    });
    for (Todo todo in todos) {
      print(todo.complete);
    }
  }
}
