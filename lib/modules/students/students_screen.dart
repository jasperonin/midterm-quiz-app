// lib/modules/students/students_screen.dart
import 'package:app/modules/students/student_details_screen.dart';
import 'package:app/utils/route_helper.dart';
import 'package:app/widgets/common/loading_indicator.dart';
import 'package:app/widgets/feedback/error_widget.dart';
import 'package:app/widgets/layouts/sidebar_layout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/routes.dart';

class StudentsScreen extends StatefulWidget {
  final String? courseId;
  final String? teacherId;

  const StudentsScreen({Key? key, this.courseId, this.teacherId})
    : super(key: key);

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  int _totalStudents = 0;
  int _activeStudents = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Handle scroll if needed, but just prevent errors
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SidebarLayout(
      teacherId: widget.teacherId ?? 'teacher_123',
      teacherName: 'Dr. Amancio',
      currentRoute: AppRoutes.students,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Students',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final total = snapshot.data!.docs.length;
                        final active = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['examStatus'] == 'active';
                        }).length;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _totalStudents = total;
                              _activeStudents = active;
                            });
                          }
                        });
                      }
                      return Text(
                        'Total: $_totalStudents students • Active: $_activeStudents',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      );
                    },
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add),
                label: const Text('Add Student'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: CustomErrorWidget(
              message: 'Error: ${snapshot.error}',
              onRetry: () => setState(() {}),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: LoadingIndicator(message: 'Loading...'));
        }

        final allDocs = snapshot.data!.docs;
        final filtered = allDocs.where((doc) {
          if (_searchQuery.isEmpty) return true;
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final id = doc.id.toLowerCase();
          final email = (data['email'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery) ||
              id.contains(_searchQuery) ||
              email.contains(_searchQuery);
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? 'No students' : 'No matches',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                if (_searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Text('Clear Search'),
                  ),
              ],
            ),
          );
        }

        return RepaintBoundary(
          child: ListView.builder(
            key: const PageStorageKey<String>('student-list'),
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            physics: const ClampingScrollPhysics(), // Use ClampingScrollPhysics
            cacheExtent: 1000, // Add cache extent
            addAutomaticKeepAlives: true,
            itemBuilder: (context, index) {
              final doc = filtered[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildStudentCard(doc.id, data);
            },
          ),
        );
      },
    );
  }

  Widget _buildStudentCard(String docId, Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unnamed Student';
    final email = data['email'] ?? '';
    final status = data['examStatus'] ?? 'inactive';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          final studentId = docId;
          debugPrint('👆 Navigating to student: $studentId');

          // Use the route helper
          final route = RouteHelper.studentDetails(studentId);
          debugPrint('📍 Route: $route');

          // Navigate using pushNamed
          Navigator.pushNamed(
                context,
                route,
                arguments: {
                  'studentId': studentId,
                  'teacherId': widget.teacherId ?? 'teacher_123',
                },
              )
              .then((value) {
                debugPrint('✅ Returned from student details');
              })
              .catchError((error) {
                debugPrint('❌ Navigation error: $error');
              });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getAvatarColor(name),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: status == 'active'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: status == 'active'
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: $docId',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return Colors.grey;
    final hash = name.codeUnits.fold(0, (a, b) => a + b);
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];
    return colors[hash % colors.length];
  }
}

  // void _showDetails(String docId, Map<String, dynamic> data) {
  //   final name = data['name'] ?? 'Unnamed';
  //   final status = data['examStatus'] ?? 'inactive';
  //   final hasTakenExam = data['hasTakenExam'] ?? false;
  //   final tabSwitchCount = data['tabSwitchCount'] ?? 0;
  //   final avgScore = data['stats']?['averageQuizScore'] ?? 0;

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) => AlertDialog(
  //       title: Row(
  //         children: [
  //           Container(
  //             width: 40,
  //             height: 40,
  //             decoration: BoxDecoration(
  //               color: Colors.blue.shade100,
  //               shape: BoxShape.circle,
  //             ),
  //             child: Center(
  //               child: Text(
  //                 _getInitials(name),
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.blue,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   name,
  //                   style: const TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 Text(
  //                   'ID: $docId',
  //                   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             _infoRow('Status', status.toUpperCase()),
  //             const SizedBox(height: 8),
  //             _infoRow('Exam Taken', hasTakenExam ? 'Yes' : 'No'),
  //             const SizedBox(height: 8),
  //             _infoRow('Tab Switches', tabSwitchCount.toString()),
  //             const SizedBox(height: 8),
  //             _infoRow('Avg Score', '$avgScore%'),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Close'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //           child: const Text('Edit'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _infoRow(String label, String value) => Row(
  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //   children: [
  //     Text(label, style: const TextStyle(fontSize: 14)),
  //     Text(
  //       value,
  //       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  //     ),
  //   ],
  // );

  // String _getInitials(String name) {
  //   if (name.isEmpty) return '?';
  //   final parts = name.trim().split(' ');
  //   if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  //   return name[0].toUpperCase();
  // }

  // Color _getAvatarColor(String name) {
  //   if (name.isEmpty) return Colors.grey;
  //   final hash = name.codeUnits.fold(0, (a, b) => a + b);
  //   const colors = [
  //     Colors.blue,
  //     Colors.green,
  //     Colors.orange,
  //     Colors.purple,
  //     Colors.teal,
  //     Colors.pink,
  //     Colors.indigo,
  //     Colors.cyan,
  //   ];
  //   return colors[hash % colors.length];
  // }

