import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language Preference'),
            subtitle: Text('Kannada (kn)'),
            trailing: Icon(Icons.edit),
          ),
          ListTile(
            leading: Icon(Icons.speed),
            title: Text('Learning Pace'),
            subtitle: Text('Medium (Detailed Step-by-Step)'),
            trailing: Icon(Icons.edit),
          ),
          ListTile(
            leading: Icon(Icons.stacked_bar_chart),
            title: Text('Weak Subjects'),
            subtitle: Text('Algebra, Trigonometry'),
          ),
        ],
      ),
    );
  }
}
