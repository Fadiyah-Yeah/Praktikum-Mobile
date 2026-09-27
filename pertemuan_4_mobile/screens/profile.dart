import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final String username;

  const Profile({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(username),
      ),
    );
  }
}
