import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';
import 'job_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final ValueNotifier<List<Job>> _jobsNotifier = ValueNotifier([]);
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      DashboardTab(jobsNotifier: _jobsNotifier),
      JobsTab(jobsNotifier: _jobsNotifier),
      InterviewsTab(),
    ];
  }

  @override
  void dispose() {
    _jobsNotifier.dispose();
    super.dispose();
  }

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
    });
  }

  List<Widget> _buildActions() {
    List<Widget> actions = [];
    actions.add(IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () {
        FirebaseAuth.instance.signOut();
        Navigator.pop(context);
      },
    ));
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        centerTitle: true,
        actions: _buildActions(),
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
              shape: const CircleBorder(), // 👈 đảm bảo hình tròn
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
  final ValueNotifier<List<Job>> jobsNotifier;

  const DashboardTab({super.key, required this.jobsNotifier});

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              final allJobs = widget.jobsNotifier.value;
              final titles = allJobs.map((job) => job.title).toSet();
              final companies = allJobs.map((job) => job.company).toSet();
              final allKeywords = titles.union(companies);
              return allKeywords.where((keyword) =>
                keyword.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (String selection) {
              setState(() {
                _searchQuery = selection;
              });
            },
            fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm công việc hoặc công ty...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400, // 👈 xám lợt
                  ),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none, 
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              );
            },
            optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width - 40,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return GestureDetector(
                          onTap: () {
                            onSelected(option);
                          },
                          child: ListTile(
                            title: Text(option),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
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

              final jobs = snapshot.data!.docs.map((doc) {
                return Job.fromFirestore(doc);
              }).toList();

              widget.jobsNotifier.value = jobs;

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
                          MaterialPageRoute(
                            builder: (context) => JobDetailPage(job: job),
                          ),
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

class JobsTab extends StatefulWidget {
  final ValueNotifier<List<Job>> jobsNotifier;

  const JobsTab({super.key, required this.jobsNotifier});

  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab> {
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

        widget.jobsNotifier.value = jobs;

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
                contentPadding: const EdgeInsets.all(15),
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
                    Text('Công ty: ${job.company}'),
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
                    MaterialPageRoute(
                      builder: (context) => JobDetailPage(job: job),
                    ),
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

class JobSearchDelegate extends SearchDelegate<Job> {
  final List<Job> jobs;

  JobSearchDelegate({required this.jobs});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Job(id: '', title: '', company: '', status: '', appliedDate: DateTime.now()));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = jobs.where((job) =>
      job.title.toLowerCase().contains(query.toLowerCase()) ||
      job.company.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final job = results[index];
        return ListTile(
          title: Text(job.title),
          subtitle: Text(job.company),
          onTap: () {
            close(context, job);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailPage(job: job),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = jobs.where((job) =>
      job.title.toLowerCase().contains(query.toLowerCase()) ||
      job.company.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final job = suggestions[index];
        return ListTile(
          title: Text(job.title),
          subtitle: Text(job.company),
          onTap: () {
            query = job.title;
            showResults(context);
          },
        );
      },
    );
  }
}

class InterviewsTab extends StatelessWidget {
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
          padding: const EdgeInsets.all(20),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return Card(
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
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
                    Text('Công ty: ${job.company}'),
                    Text('Ngày phỏng vấn: ${job.interviewDate!.toLocal().toString().split(' ')[0]}'),
                  ],
                ),
                trailing: const Icon(
                  Icons.calendar_today,
                  color: Colors.blueAccent,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
