// lib/modules/dashboard/widgets/recent_activity_list.dart
import 'package:app/models/dashboard_data.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';

class RecentActivityList extends StatefulWidget {
  final List<RecentActivity> activities;
  final VoidCallback onLoadMore;
  final bool hasMore;

  const RecentActivityList({
    Key? key,
    required this.activities,
    required this.onLoadMore,
    required this.hasMore,
  }) : super(key: key);

  @override
  State<RecentActivityList> createState() => _RecentActivityListState();
}

class _RecentActivityListState extends State<RecentActivityList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (widget.hasMore) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: widget.activities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    itemCount:
                        widget.activities.length + (widget.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == widget.activities.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final activity = widget.activities[index];
                      return _buildActivityItem(activity);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(RecentActivity activity) {
    IconData iconData;
    Color iconColor;

    switch (activity.activityType) {
      case 'quiz_completed':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'quiz_started':
        iconData = Icons.play_circle;
        iconColor = Colors.blue;
        break;
      case 'violation':
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.info;
        iconColor = Colors.grey;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(iconData, color: iconColor, size: 20),
      ),
      title: Text(
        activity.studentName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(activity.description),
      trailing: Text(
        DateFormatter.getRelativeTime(activity.timestamp),
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No recent activity',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
