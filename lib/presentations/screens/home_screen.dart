import 'package:flutter/material.dart';
import 'package:scout/mocks/mock_activities.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userPhone =
      '9876543210'; // TODO: Replace with actual logged-in user's phone

  @override
  Widget build(BuildContext context) {
    final activities = List<Activity>.from(mockActivities)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Activities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Activity',
            onPressed: () => Navigator.pushNamed(context, '/add_activity'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                // This will rebuild the widget and reload the list
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            title: Text(activity.title),
            subtitle: Text(
              '${activity.dateTime.year}-${activity.dateTime.month.toString().padLeft(2, '0')}-${activity.dateTime.day.toString().padLeft(2, '0')} '
              '${activity.dateTime.hour.toString().padLeft(2, '0')}:${activity.dateTime.minute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/activity_details',
                  arguments: activity.id);
            },
          );
        },
      ),
    );
  }
}
