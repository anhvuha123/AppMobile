import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_tracker/pages/login_page.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/job.dart';
import 'job_detail_page.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  final String? highlightJobId;

  const HomePage({super.key, this.initialIndex = 0, this.highlightJobId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _highlightJobId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Widget> get _widgetOptions => <Widget>[
        const DashboardTab(),
        JobsTab(),
        InterviewsTab(highlightedJobId: _highlightJobId),
      ];

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return "Trang Chủ";
      case 1:
        return "Đơn";
      case 2:
        return "Lịch Phỏng Vấn";
      default:
        return "Trang Chủ";
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 2) _highlightJobId = null; // clear highlight when leaving Interviews
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _highlightJobId = widget.highlightJobId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: SizedBox(
            width: 72,
            height: 72,
            child: FloatingActionButton(
              shape: const CircleBorder(), 
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
              backgroundColor: Colors.blueAccent,
              elevation: 8,
              child: const Icon(
                Icons.dashboard,
                size: 42,
                color: Colors.white,
              ),
            ),
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              onTap: () => _onItemTapped(1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 30,
                    color: _selectedIndex == 1 ? Colors.blueAccent : Colors.grey,
                  ),
                  Text(
                    'Đơn',
                    style: TextStyle(
                      color: _selectedIndex == 1 ? Colors.blueAccent : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40), // Space for FAB
            GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 30,
                    color: _selectedIndex == 2 ? Colors.blueAccent : Colors.grey,
                  ),
                  Text(
                    'Lịch PV',
                    style: TextStyle(
                      color: _selectedIndex == 2 ? Colors.blueAccent : Colors.grey,
                      fontSize: 12,
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

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Chào mừng bạn!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Email: ${user?.email ?? user?.phoneNumber ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm công việc hoặc công ty...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Danh sách ứng tuyển:",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('jobs').orderBy('appliedDate', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final jobs = snapshot.data!.docs.map((doc) => Job.fromFirestore(doc)).toList();

              final filteredJobs = _searchQuery.isEmpty
                ? jobs
                : jobs.where((job) =>
                    job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    job.company.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();

              if (filteredJobs.isEmpty) {
                return const Center(
                  child: Text(
                    'Không tìm thấy kết quả.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: filteredJobs.length,
                itemBuilder: (context, index) {
                  final job = filteredJobs[index];
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            job.company,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trạng thái: ${job.status}'),
                          Text('Ngày ứng tuyển: ${job.appliedDate.toLocal().toString().split(' ')[0]}'),
                        ],
                      ),
                      trailing: Icon(
                        job.status == 'Accepted' ? Icons.check_circle : Icons.pending,
                        color: job.status == 'Accepted' ? Colors.green : Colors.orange,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => JobDetailPage(job: job)),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class JobsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').orderBy('appliedDate', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = snapshot.data!.docs.map((doc) {
          return Job.fromFirestore(doc);
        }).toList();

        if (jobs.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có đơn ứng tuyển nào.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            Color statusColor;
            IconData statusIcon;
            switch (job.status.toLowerCase()) {
              case 'pending':
                statusColor = Colors.orange;
                statusIcon = Icons.pending;
                break;
              case 'accepted':
              case 'pass':
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                break;
              case 'rejected':
              case 'fail':
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                break;
              default:
                statusColor = Colors.grey;
                statusIcon = Icons.help;
            }
            return Card(
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(15, 2, 15, 12),
                minVerticalPadding: 0,
                title: Text(
                  job.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Công ty: ${job.company}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Text('Trạng thái: ${job.status}'),
                    Text('Ngày ứng tuyển: ${job.appliedDate.toLocal().toString().split(' ')[0]}'),
                  ],
                ),
                trailing: Icon(
                  statusIcon,
                  color: statusColor,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JobDetailPage(job: job)),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class InterviewsTab extends StatefulWidget {
  final String? highlightedJobId;

  const InterviewsTab({super.key, this.highlightedJobId});

  @override
  State<InterviewsTab> createState() => _InterviewsTabState();
}

class _InterviewsTabState extends State<InterviewsTab> {
  final ScrollController _scrollController = ScrollController();
  String? _activeHighlightId;

  IconData _getInterviewTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'phone':
        return Icons.phone;
      case 'video':
        return Icons.videocam;
      case 'in-person':
        return Icons.location_on;
      default:
        return Icons.calendar_today;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
  @override
  void initState() {
    super.initState();
    _activeHighlightId = widget.highlightedJobId;
  }

  @override
  void didUpdateWidget(covariant InterviewsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedJobId != oldWidget.highlightedJobId) {
      setState(() {
        _activeHighlightId = widget.highlightedJobId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = snapshot.data!.docs.map((doc) {
          return Job.fromFirestore(doc);
        }).where((job) => job.interviewDate != null).toList();

        if (jobs.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có lịch phỏng vấn nào.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            final bool highlighted = _activeHighlightId != null && _activeHighlightId == job.id;

            final card = Card(
              color: highlighted ? const Color(0xFFFFF7E0) : null,
              elevation: highlighted ? 12 : 8,
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                side: highlighted ? BorderSide(color: Colors.orange.shade300, width: 2) : BorderSide.none,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getInterviewTypeIcon(job.interviewType),
                          color: Colors.blueAccent,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildInfoRow(Icons.business, 'Công ty', job.company),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.calendar_today, 'Ngày phỏng vấn', job.interviewDate!.toLocal().toString().split(' ')[0]),
                    if (job.interviewer != null) ...[
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.person, 'Người phỏng vấn', job.interviewer!),
                    ],
                    if (job.interviewLocation != null) ...[
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.location_on, 'Địa điểm', job.interviewLocation!),
                    ],
                    if (job.interviewType != null) ...[
                      const SizedBox(height: 10),
                      _buildInfoRow(_getInterviewTypeIcon(job.interviewType), 'Loại phỏng vấn', job.interviewType!),
                    ],
                  ],
                ),
              ),
            );

            // If this is the highlighted job, schedule a scroll-to and clear highlight after a delay
            if (highlighted) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final itemOffset = index * 200.0; // approximate item height, OK for now
                await _scrollController.animateTo(
                  itemOffset,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
                // remove highlight after a short delay
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      _activeHighlightId = null;
                    });
                  }
                });
              });
            }

            return card;
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
