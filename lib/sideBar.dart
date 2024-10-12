import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(title: const Text("Home"),
          leading: const Icon(Icons.home),
          onTap: (){},),
                    ListTile(title: const Text("plans"),
          leading: const Icon(Icons.drive_file_rename_outline),
          onTap: (){},),
        ],
      )
    );
  }
}