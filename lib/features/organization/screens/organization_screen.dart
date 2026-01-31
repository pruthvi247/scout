import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/organization_model.dart';
import '../providers/organization_provider.dart';

class OrganizationScreen extends ConsumerWidget {
  const OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(organizationTreeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(organizationTreeProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, OrganizationTreeState state) {
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
              'Error loading organization',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (state.tree == null) {
      return const Center(child: Text('No organization data available'));
    }

    final roots = state.tree!.roots;
    if (roots.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No organization nodes found'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_tree,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Organization Structure',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Nodes: ${state.tree!.totalNodes}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Display all root nodes
        ...roots.map((root) => _OrganizationNodeTile(node: root)),
      ],
    );
  }
}

class _OrganizationNodeTile extends StatefulWidget {
  final OrganizationNode node;
  final int indent;

  const _OrganizationNodeTile({required this.node, this.indent = 0});

  @override
  State<_OrganizationNodeTile> createState() => _OrganizationNodeTileState();
}

class _OrganizationNodeTileState extends State<_OrganizationNodeTile> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final hasChildren =
        widget.node.children != null && widget.node.children!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(left: widget.indent * 16.0, bottom: 8),
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                _getNodeIcon(widget.node.type),
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                widget.node.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.node.type.toUpperCase()} • ${widget.node.memberCount} members',
                  ),
                  if (widget.node.activitySummary != null &&
                      widget.node.activitySummary!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Activities: ${_getActivitySummaryText(widget.node.activitySummary!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: SizedBox(
                width: hasChildren && widget.node.memberCount > 0 ? 96 : 48,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.node.memberCount > 0)
                      IconButton(
                        icon: const Icon(Icons.people),
                        tooltip: 'View Members',
                        onPressed: () => _showNodeMembers(context),
                      ),
                    if (hasChildren)
                      IconButton(
                        icon: Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                        ),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (_isExpanded && hasChildren)
              ...widget.node.children!.map(
                (child) => _OrganizationNodeTile(
                  node: child,
                  indent: widget.indent + 1,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getActivitySummaryText(Map<String, dynamic> summary) {
    final total = summary['total'] ?? 0;
    final verified = summary['verified'] ?? 0;
    final pending = summary['pending'] ?? 0;
    return '$total total ($verified verified, $pending pending)';
  }

  void _showNodeMembers(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _NodeMembersDialog(node: widget.node),
    );
  }

  IconData _getNodeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'state':
        return Icons.map;
      case 'district':
        return Icons.location_city;
      case 'mandal':
        return Icons.business;
      case 'village':
        return Icons.home_work;
      case 'ward':
        return Icons.holiday_village;
      case 'booth':
        return Icons.store;
      default:
        return Icons.folder;
    }
  }
}

class _NodeMembersDialog extends ConsumerWidget {
  final OrganizationNode node;

  const _NodeMembersDialog({required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersState = ref.watch(nodeMembersProvider(node.id));

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        child: Column(
          children: [
            AppBar(
              title: Text('Members - ${node.name}'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(child: _buildMembersBody(context, membersState)),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersBody(BuildContext context, NodeMembersState state) {
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
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading members',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    if (state.members.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48),
            SizedBox(height: 16),
            Text('No members assigned to this node'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.members.length,
      itemBuilder: (context, index) {
        final member = state.members[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(member.fullName[0].toUpperCase()),
            ),
            title: Text(member.fullName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.role.toUpperCase()),
                if (member.email.isNotEmpty) Text(member.email),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/members/${member.id}');
              },
            ),
          ),
        );
      },
    );
  }
}
