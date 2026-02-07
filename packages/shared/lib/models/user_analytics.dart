class UserAnalytics {
  final int totalViews;
  final int interestsReceived;
  final int shortlistedBy;
  final int interestsSent;

  UserAnalytics({
    required this.totalViews,
    required this.interestsReceived,
    required this.shortlistedBy,
    required this.interestsSent,
  });

  Map<String, dynamic> toMap() {
    return {
      'total_views': totalViews,
      'interests_received': interestsReceived,
      'shortlisted_by': shortlistedBy,
      'interests_sent': interestsSent,
    };
  }

  factory UserAnalytics.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserAnalytics(
        totalViews: 0,
        interestsReceived: 0,
        shortlistedBy: 0,
        interestsSent: 0,
      );
    }
    return UserAnalytics(
      totalViews: (map['total_views'] as num?)?.toInt() ?? 0,
      interestsReceived: (map['interests_received'] as num?)?.toInt() ?? 0,
      shortlistedBy: (map['shortlisted_by'] as num?)?.toInt() ?? 0,
      interestsSent: (map['interests_sent'] as num?)?.toInt() ?? 0,
    );
  }
}
