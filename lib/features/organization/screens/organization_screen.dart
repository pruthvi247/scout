import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        _OrganizationNodeTile(node: state.tree!.root),
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

    return Card(
      margin: EdgeInsets.only(left: widget.indent * 24.0, bottom: 8),
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
            subtitle: Text(
              '${widget.node.type.toUpperCase()} • ${widget.node.memberCount} members',
            ),
            trailing: hasChildren
                ? IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  )
                : null,
          ),
          if (_isExpanded && hasChildren)
            ...widget.node.children!.map(
              (child) =>
                  _OrganizationNodeTile(node: child, indent: widget.indent + 1),
            ),
        ],
      ),
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
