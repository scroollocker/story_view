import 'package:example/data.dart';
import 'package:flutter/material.dart';
import 'package:stories/stories.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Stories(
              stories: stories,
              cells: [cell, cell1, cell2],
            ),
          ),
        ),
      ),
    );
  }
}
