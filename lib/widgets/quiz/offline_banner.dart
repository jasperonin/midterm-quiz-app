// lib/widgets/quiz/offline_banner.dart
import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final bool isVisible;
  final bool hasQuestions;

  const OfflineBanner({
    Key? key,
    required this.isVisible,
    required this.hasQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: Colors.orange,
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasQuestions
                  ? 'Offline Mode - Answers will sync when online'
                  : 'Offline Mode - Using cached questions',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}