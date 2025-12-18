import 'package:connectify/services/auth_services.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Profile View"),
          ElevatedButton(
            onPressed: () async {
            await AuthServices().logout(context);
          }, child: 
          Text("Logout"),
          ),
        ],
      ),
    );
  }
}
