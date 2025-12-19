class Job {
  final String id;
  final String title;
  final String company;
  final String status;
  final DateTime appliedDate;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.status,
    required this.appliedDate,
  });

  factory Job.fromMap(String id, Map<String, dynamic> data) {
    return Job(
      id: id,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      status: data['status'] ?? 'Applied',
      appliedDate: DateTime.parse(data['appliedDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'status': status,
      'appliedDate': appliedDate.toIso8601String(),
    };
  }
}