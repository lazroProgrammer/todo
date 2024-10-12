import 'package:localstore/localstore.dart';

class Page{
  static final db = Localstore.instance;

  String id;
  String text;
  Page({required this.id, required this.text});

  factory Page.fromJson(Map<String, dynamic> json , String id) {
    return Page(
        id: id,
        text: json["title"] as String,
    );
  }

  static String add(String text,) {
    final id = db.collection("todo").doc().id;
    db.collection("todo").doc(id).set({
      'title': text,
    });
    return id;
  }
  static Future<List<Page>> getList() async {
    List<Page> items=[];
    final json=await db.collection("pages").get();

      print( json.toString());
      if(json == null){
        return[];
      }

      json.forEach((key, value) {
      String yek=key.split('').reversed.join();
      String identity=yek.substring(0,yek.indexOf('/'));
      identity=identity.split('').reversed.join();
       
      items.add(Page.fromJson(value, identity));
    });
    for(Page item in items){
      print("id: ${item.id}, content: ${item.text}");
    }
    return items;

  }
  void deleteItem(){
    db.collection("Pages").doc(id).delete();
  }

}