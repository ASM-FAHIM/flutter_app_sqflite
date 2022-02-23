import 'package:flutter/material.dart';
import 'package:flutter_app_sqflite/myHomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Employee List',
        theme: ThemeData(
            primarySwatch: Colors.blue),
        home:  MyHomePage());
  }
}