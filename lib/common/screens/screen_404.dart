import 'package:flutter/material.dart';
class Screen404 extends StatefulWidget {
  final String  title;
  final String  message;
  const Screen404({super.key,required this.title,required this.message});

  @override
  State<Screen404> createState() => _Screen404State();
}

class _Screen404State extends State<Screen404> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

        ],
      ),
    );
  }
}
