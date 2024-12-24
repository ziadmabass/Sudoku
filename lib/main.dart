import 'package:flutter/material.dart';
import 'package:suduko/sudoko.dart';
void main(){
  runApp(const MyWidget());
}
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SudokuGame(),
    );
  }
}