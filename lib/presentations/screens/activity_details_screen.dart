import 'package:flutter/material.dart';
import 'package:scout/mocks/mock_activities.dart';

class ActivityDetailsScreen extends StatelessWidget {
  const ActivityDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? activityId =
        ModalRoute.of(context)?.settings.arguments as String?;
    final activity = mockActivities.firstWhere(
      (a) => a.id == activityId,
      orElse: () =>
          Activity(id: '', title: 'Not found', dateTime: DateTime.now()),
    );
    // For now, only show title and date/time. Extend as needed.
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Details')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${activity.title}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Date/Time: ${activity.dateTime}'),
            // TODO: Show address, service type, reviewer, comments, images, etc. when available in Activity model
          ],
        ),
      ),
    );
  }
}
