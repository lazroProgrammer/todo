import 'package:localstore/localstore.dart';

class TodoItem {
  static final db = Localstore.instance;

  String id;
  String text;
 // DateTime? doneOn;
  String? doneOn;
  bool done;

  TodoItem(
      {
      required this.id,
      required this.text,
      //required this.deadline,
      required this.done,
      required this.doneOn
      //required this.doneOn});
      }
  );

  factory TodoItem.fromJson(Map<String, dynamic> json , String id) {
    return TodoItem(
        id: id,
        text: json["title"] as String,
        //deadline: json["deadline"] as DateTime?,
        done: json["done"] as bool,
        doneOn: json["done on"] as String?
    );
  }
// , DateTime? deadline
  static String addItem(String text,) {

    final id = db.collection("todo").doc().id;
    db.collection("todo").doc(id).set({
      'title': text,
   //   'deadline': "${deadline.day}",
      'done': false,
      'done on': null,
    });
    return id;
  }

  static Future<List<TodoItem>> getTodoList() async {
    List<TodoItem> items = [];
    final todoList = await db.collection("todo").get();

    print( todoList.toString());
    if (todoList == null) {
      return [];
    }

    todoList.forEach((key, value) {
      String yek=key.split('').reversed.join();
      String identity=yek.substring(0,yek.indexOf('/'));
      identity=identity.split('').reversed.join();
       
      items.add(TodoItem.fromJson(value, identity));
    });
    for(TodoItem item in items){
      print("id: ${item.id}, content: ${item.text}, checked: ${item.done}");
    }
    return items;
  }

  void checkItem(bool check, String? time){
    db.collection("todo").doc(id).set({
      'title': text,
   //   'deadline': "${deadline.day}",
    //  'done on': null,
      'done': check,
      'done on': time,
    });

  }

  void editItem(String newText){

    db.collection("todo").doc(id).delete();
            final newId = db.collection("todo").doc().id;
     db.collection("todo").doc(newId).set({
      'title': newText,
   //   'deadline': "${deadline.day}",
      'done': done,
      'done on': doneOn,
    });
    id=newId;

  }

  void deleteItem(){
    db.collection("todo").doc(id).delete();
  }
}
