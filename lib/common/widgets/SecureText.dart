import 'package:flutter/material.dart';

import '../../core/storage/secure_storage.dart';

class SecureText extends StatelessWidget {
  final String prefKey;
  final TextStyle style;
  final String defaultValue;

  const SecureText({
    super.key,
    required this.prefKey,
    required this.style,
    this.defaultValue = 'User',
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: SecurePreference().getString(
        prefKey,
        defaultValue: defaultValue,
      ),
      builder: (context, snapshot) {
        return Text(
          snapshot.data ?? defaultValue,
          style: style,
        );
      },
    );
  }
}
