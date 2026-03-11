// lib/shared/widgets/feedback/loading_indicator.dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;
  final bool showProgress;

  const LoadingIndicator({
    Key? key,
    this.message = 'Loading...',
    this.showProgress = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showProgress) const CircularProgressIndicator(),
          if (showProgress) const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
