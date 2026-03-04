// lib/live_monitoring.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './view/home.dart';
import 'firebase_options.dart';
import './utils/platform_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized for monitoring');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  runApp(const MonitoringApp());
}

class MonitoringApp extends StatelessWidget {
  const MonitoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if running on web
    const bool isWeb = identical(0, 0.0);

    if (isWeb) {
      return FlutterWebFrame(
        builder: (context) {
          return MaterialApp(
            title: 'Live Monitoring',
            theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
            home: const LiveMonitoringScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
        maximumSize: const Size(400, 830), // Fixed size like main app
        backgroundColor: Colors.grey.shade300,
        enabled: true,
      );
    } else {
      // Mobile version without frame
      return MaterialApp(
        title: 'Live Monitoring',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const LiveMonitoringScreen(),
        debugShowCheckedModeBanner: false,
      );
    }
  }
}

// Rest of your LiveMonitoringScreen class remains exactly the same...
class LiveMonitoringScreen extends StatefulWidget {
  const LiveMonitoringScreen({Key? key}) : super(key: key);

  @override
  _LiveMonitoringScreenState createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Rankings'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: // In live_monitoring.dart - Update the data processing section
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .orderBy('lastActive', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Process users for ranking
            List<Map<String, dynamic>> rankedStudents = [];

            for (var doc in snapshot.data!.docs) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              bool hasTakenExam = data['hasTakenExam'] ?? false;
              String examStatus = data['examStatus'] ?? 'inactive';

              // 👇 FILTER: Skip students who haven't started
              if (!hasTakenExam && examStatus == 'inactive') {
                print('⏭️ Skipping ${doc.id} - not started');
                continue; // Skip this student
              }

              rankedStudents.add({
                'id': doc.id,
                'lastName': data['last_name'] ?? 'Unknown',
                'firstName': data['first_name'] ?? '',
                'examStatus': examStatus,
                'hasTakenExam': hasTakenExam,
                'lastActive': data['lastActive'],
              });
            }

            // Sort by status (active first) then by name
            rankedStudents.sort((a, b) {
              // Currently taking exam first
              if (a['examStatus'] == 'active' && b['examStatus'] != 'active')
                return -1;
              if (a['examStatus'] != 'active' && b['examStatus'] == 'active')
                return 1;

              // Then completed vs not (though not started are filtered out)
              if (a['hasTakenExam'] && !b['hasTakenExam']) return -1;
              if (!a['hasTakenExam'] && b['hasTakenExam']) return 1;

              // Then by last name
              return a['lastName'].compareTo(b['lastName']);
            });

            // Filter by search query
            if (_searchQuery.isNotEmpty) {
              rankedStudents = rankedStudents.where((student) {
                return student['id'].toLowerCase().contains(_searchQuery) ||
                    student['lastName'].toLowerCase().contains(_searchQuery) ||
                    student['firstName'].toLowerCase().contains(_searchQuery);
              }).toList();
            }

            if (rankedStudents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No students have started the exam yet'
                          : 'No matching students',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Rest of your UI code...
            return Column(
              children: [
                // Summary stats (update counts to reflect filtered students)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Active',
                        rankedStudents
                            .where((s) => s['examStatus'] == 'active')
                            .length
                            .toString(),
                        Icons.bolt,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Completed',
                        rankedStudents
                            .where((s) => s['hasTakenExam'])
                            .length
                            .toString(),
                        Icons.check_circle,
                        Colors.purple,
                      ),
                      _buildStatCard(
                        'Total',
                        rankedStudents.length.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),

                // Rankings header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        '📊 STUDENT RANKINGS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${rankedStudents.length} active',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Rankings list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: rankedStudents.length,
                    itemBuilder: (context, index) {
                      var student = rankedStudents[index];
                      return _buildRankingCard(student, index + 1);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Student'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter ID or Last Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value.toLowerCase().trim();
            });
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildRankingCard(Map<String, dynamic> student, int rank) {
    Color rankColor = Colors.grey.shade300;
    String rankDisplay = '#$rank';

    if (rank == 1) {
      rankColor = Colors.amber;
      rankDisplay = '🥇';
    } else if (rank == 2) {
      rankColor = Colors.grey.shade400;
      rankDisplay = '🥈';
    } else if (rank == 3) {
      rankColor = Colors.brown.shade300;
      rankDisplay = '🥉';
    }

    // 👇 FIXED STATUS LOGIC - hasTakenExam takes priority
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (student['hasTakenExam'] == true) {
      // Student has completed the exam (regardless of examStatus)
      statusColor = Colors.purple;
      statusText = 'Completed';
      statusIcon = Icons.check_circle;
    } else if (student['examStatus'] == 'active') {
      // Student is currently taking the exam
      statusColor = Colors.green;
      statusText = 'Taking exam';
      statusIcon = Icons.bolt;
    } else {
      // Student hasn't started
      statusColor = Colors.grey;
      statusText = 'Not started';
      statusIcon = Icons.hourglass_empty;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Rank
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  rankDisplay,
                  style: TextStyle(
                    fontSize: rank <= 3 ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: rankColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Student info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        student['id'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    student['lastName'],
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Status - now correctly shows Completed even if examStatus is active
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
