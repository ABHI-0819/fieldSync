import 'package:flutter/material.dart';


class Screen404 extends StatelessWidget {
  final String title;
  final String message;

  const Screen404({
    super.key,
    this.title = '404',
    this.message = 'This is a dead end',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
      ),
    );
  }
}
