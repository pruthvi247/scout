import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/volunteer_provider.dart';
import '../../../models/volunteer_model.dart';

class VolunteerAssignmentsScreen extends ConsumerStatefulWidget {
  final int volunteerId;

  const VolunteerAssignmentsScreen({super.key, required this.volunteerId});

  @override
  ConsumerState<VolunteerAssignmentsScreen> createState() =>
      _VolunteerAssignmentsScreenState();
}

class _VolunteerAssignmentsScreenState
    extends ConsumerState<VolunteerAssignmentsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(volunteerAssignmentsProvider(widget.volunteerId));

    return Scaffold(
      appBar: AppBar(title: const Text('My Assignments')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(volunteerAssignmentsProvider(widget.volunteerId).notifier)
              .loadAssignments();
        },
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(VolunteerAssignmentsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading assignments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref
                    .read(
                      volunteerAssignmentsProvider(widget.volunteerId).notifier,
                    )
                    .loadAssignments();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.assignments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64),
            SizedBox(height: 16),
            Text('No assignments yet'),
          ],
        ),
      );
    }

    final pendingAssignments = state.assignments
        .where((a) => a.status == 'pending')
        .toList();
    final inProgressAssignments = state.assignments
        .where((a) => a.status == 'in_progress')
        .toList();
    final completedAssignments = state.assignments
        .where((a) => a.status == 'completed')
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pendingAssignments.isNotEmpty) ...[
          _buildSectionHeader('Pending', pendingAssignments.length),
          ...pendingAssignments.map(
            (assignment) => AssignmentCard(
              assignment: assignment,
              volunteerId: widget.volunteerId,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (inProgressAssignments.isNotEmpty) ...[
          _buildSectionHeader('In Progress', inProgressAssignments.length),
          ...inProgressAssignments.map(
            (assignment) => AssignmentCard(
              assignment: assignment,
              volunteerId: widget.volunteerId,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (completedAssignments.isNotEmpty) ...[
          _buildSectionHeader('Completed', completedAssignments.length),
          ...completedAssignments.map(
            (assignment) => AssignmentCard(
              assignment: assignment,
              volunteerId: widget.volunteerId,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text(count.toString()),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class AssignmentCard extends ConsumerWidget {
  final Assignment assignment;
  final int volunteerId;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.volunteerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(assignment.status, theme),
              ],
            ),
            const SizedBox(height: 8),
            Text(assignment.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Assigned: ${DateFormat('MMM d, y').format(assignment.assignedAt)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            if (assignment.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.alarm,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${DateFormat('MMM d, y').format(assignment.dueDate!)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            if (assignment.status != 'completed') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (assignment.status == 'pending')
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(ref, 'in_progress'),
                        child: const Text('Start'),
                      ),
                    ),
                  if (assignment.status == 'in_progress') ...[
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _updateStatus(ref, 'completed'),
                        child: const Text('Complete'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _updateStatus(WidgetRef ref, String newStatus) {
    ref
        .read(volunteerAssignmentsProvider(volunteerId).notifier)
        .updateAssignmentStatus(assignment.assignmentId, newStatus);
  }
}
