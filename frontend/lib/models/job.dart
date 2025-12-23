import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String company;
  final String status;
  final DateTime appliedDate;
  final DateTime? interviewDate;
  final String? interviewer;
  final String? interviewLocation;
  final String? interviewType;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.status,
    required this.appliedDate,
    this.interviewDate,
    this.interviewer,
    this.interviewLocation,
    this.interviewType,
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Job.fromMap(doc.id, data);
  }

  factory Job.fromMap(String id, Map<String, dynamic> data) {
    return Job(
      id: id,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      status: data['status'] ?? 'Applied',
      appliedDate: (data['appliedDate'] as Timestamp).toDate(),
      interviewDate: data['interviewDate'] != null ? (data['interviewDate'] as Timestamp).toDate() : null,
      interviewer: data['interviewer'],
      interviewLocation: data['interviewLocation'],
      interviewType: data['interviewType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'status': status,
      'appliedDate': Timestamp.fromDate(appliedDate),
      if (interviewDate != null) 'interviewDate': Timestamp.fromDate(interviewDate!),
      if (interviewer != null) 'interviewer': interviewer,
      if (interviewLocation != null) 'interviewLocation': interviewLocation,
      if (interviewType != null) 'interviewType': interviewType,
    };
  }
}