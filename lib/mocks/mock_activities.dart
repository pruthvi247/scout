class Activity {
  final String id;
  final String title;
  final DateTime dateTime;

  Activity({required this.id, required this.title, required this.dateTime});
}

final List<Activity> mockActivities = [
  Activity(
      id: '1',
      title: 'Tree Plantation',
      dateTime: DateTime(2025, 5, 28, 10, 0)),
  Activity(
      id: '2',
      title: 'Food Distribution',
      dateTime: DateTime(2025, 5, 27, 16, 30)),
  Activity(
      id: '3',
      title: 'Blood Donation Camp',
      dateTime: DateTime(2025, 5, 25, 9, 0)),
];
