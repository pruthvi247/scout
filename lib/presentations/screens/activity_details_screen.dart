import 'package:flutter/material.dart';

class ActivityDetailsScreen extends StatelessWidget {
  const ActivityDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Details')),
      body: Center(
        child: Text('Activity Details Screen'),
      ),
    );
  }
}
