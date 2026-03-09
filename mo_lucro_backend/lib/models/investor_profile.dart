import 'dart:convert';

/// Investor profile from quiz results.
class InvestorProfile {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> answers;
  final String profileType;
  final int score;
  final DateTime completedAt;
  final DateTime createdAt;

  const InvestorProfile({
    required this.id,
    required this.userId,
    required this.answers,
    required this.profileType,
    required this.score,
    required this.completedAt,
    required this.createdAt,
  });

  factory InvestorProfile.fromRow(Map<String, dynamic> row) {
    final answersRaw = row['answers'];
    List<Map<String, dynamic>> answers;
    if (answersRaw is String) {
      answers = (jsonDecode(answersRaw) as List)
          .cast<Map<String, dynamic>>();
    } else if (answersRaw is List) {
      answers = answersRaw.cast<Map<String, dynamic>>();
    } else {
      answers = [];
    }

    return InvestorProfile(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      answers: answers,
      profileType: row['profile_type'] as String,
      score: row['score'] as int,
      completedAt: DateTime.parse(row['completed_at'].toString()),
      createdAt: DateTime.parse(row['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'profileType': profileType,
      'score': score,
      'answers': answers,
      'completedAt': completedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
