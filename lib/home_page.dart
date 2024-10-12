//import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:quickalert/quickalert.dart';
import 'package:todo/db/todo_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomePage> {
  List<TodoItem> todo = [];
  final TextEditingController _task = TextEditingController();
  int mode = 0;
  bool deleteMode = false;
  bool editMode = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      List<TodoItem> items = [];
      items = await TodoItem.getTodoList();
      for (TodoItem i in items) {
        todo.add(i);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              deleteMode ? "deleteMode title".i18n() : "homePage title".i18n()),
        actions: [
          IconButton(onPressed: (){}, icon:const Icon(Icons.add))
        ],
        ),
        
        drawer: const Drawer(),
        body: Column(children: [
          Expanded(
            child: ListView.builder(
              itemCount: todo.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(todo[index].text),
                  subtitle: Text(
                      "${!todo[index].done ? "" : "Completed in:"}  ${todo[index].doneOn ?? ""}"),
                  value: todo[index].done,
                  onChanged: (check) {
                    //delete mode
                    if (mode == 2) {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.confirm,
                        onConfirmBtnTap: () {
                          todo[index].deleteItem();
                          todo.remove(todo[index]);
                          Navigator.pop(context);
                          setState(() {});
                        },
                      );
                    }
                    //edit mode
                    else if (mode == 1) {
                      TextEditingController editCtrl=TextEditingController(text:todo[index].text);
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.confirm,
                        title: "edit task?".i18n(),
                        widget: TextFormField(
                          controller: editCtrl,
                          // decoration: const InputDecoration(
                          //   hintText: "enter text here",
                          // ),
                        ),
                        onConfirmBtnTap: () {
                          neededChecksToInsert(
                              context, todo, editCtrl.text, index);
                          Navigator.pop(context);
                          setState(() {});
                        },
                        cancelBtnText: "cancel",
                        onCancelBtnTap: () {
                          _task.text = '';
                          Navigator.pop(context);
                        },
                      );

                      setState(() {});

                      _task.text = "";
                    }
                    //normal mode
                    else {
                      DateTime time = DateTime.now();
                      String minute = (time.minute - 10) >= 0
                          ? "${time.minute}"
                          : "0${time.minute}";
                      String hour = (time.hour - 10) >= 0
                          ? "${time.hour}"
                          : "0${time.hour}";
                      String? doneOn = (!check!)
                          ? null
                          : "${time.day}-${time.month}-${time.year} at $hour:$minute";
                      setState(() {
                        todo[index].done = check;
                        todo[index].doneOn = doneOn;
                        todo[index].checkItem(check, doneOn);
                      });
                    }
                  },
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: (mode != 0)
                      ? null
                      : () async {
                          await QuickAlert.show(
                            context: context,
                            type: QuickAlertType.confirm,
                            title: "New task?".i18n(),
                            widget: TextFormField(
                              controller: _task,
                              decoration: InputDecoration(
                                hintText: "enter text here".i18n(),
                              ),
                            ),
                            onConfirmBtnTap: () {
                              neededChecksToInsert(
                                  context, todo, _task.text, null);
                              Navigator.pop(context);
                            },
                            cancelBtnText: "cancel",
                            onCancelBtnTap: () {
                              _task.text = '';
                              Navigator.pop(context);
                            },
                          );

                          setState(() {});

                          _task.text = "";
                        },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: FloatingActionButton(
                  child: (mode == 1)
                      ? const Icon(Icons.cancel_outlined)
                      : const Icon(Icons.edit),
                  onPressed: () {
                    if (mode != 1) {
                      mode = 1;
                    } else {
                      mode = 0;
                    }
                    setState(() {});
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: FloatingActionButton(
                  child: (mode == 2)
                      ? const Icon(Icons.cancel_outlined)
                      : const Icon(Icons.delete),
                  onPressed: () {
                    if (mode != 2) {
                      mode = 2;
                    } else {
                      mode = 0;
                    }
                    setState(() {});
                  },
                ),
              ),
            ],
          )
        ]),
      ),
    );
  }
}

bool checkSimilarities(List<TodoItem> items, String newTodo) {
  for (TodoItem item in items) {
    if (item.text == newTodo) return false;
  }
  return true;
}

void showErrorAlert(BuildContext context, String errorMessage) {
  QuickAlert.show(
      context: context, type: QuickAlertType.error, text: errorMessage);
}

void neededChecksToInsert(
    BuildContext context, List<TodoItem> todo, String task, int? index) {
  if (index != null) {
    if (task != '' && checkSimilarities(todo, task)) {
      todo[index].editItem(task);
      todo[index].text = task;
    } else {
      if (task == '') {
        showErrorAlert(context, "you need to enter a task to add it");
      }
      if (!checkSimilarities(todo, task)) {
        showErrorAlert(context, "you have already added this task");
      }
    }
  } else {
    if (task != '' && checkSimilarities(todo, task)) {
      String itemId = TodoItem.addItem(task);
      todo.add(TodoItem(
          id: itemId,
          text: task,
          //deadline: results.first,
          done: false,
          doneOn: null));
    } else {
      if (task == '') {
        showErrorAlert(context, "you need to enter a task to add it");
      }
      if (!checkSimilarities(todo, task)) {
        showErrorAlert(context, "you have already added this task");
      }
    }
  }
}
