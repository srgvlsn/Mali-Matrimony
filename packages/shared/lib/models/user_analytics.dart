class UserAnalytics {
  final int totalViews;
  final int interestsReceived;
  final int shortlistedBy;

  UserAnalytics({
    required this.totalViews,
    required this.interestsReceived,
    required this.shortlistedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'total_views': totalViews,
      'interests_received': interestsReceived,
      'shortlisted_by': shortlistedBy,
    };
  }

  factory UserAnalytics.fromMap(Map<String, dynamic> map) {
    return UserAnalytics(
      totalViews: map['total_views'] as int? ?? 0,
      interestsReceived: map['interests_received'] as int? ?? 0,
      shortlistedBy: map['shortlisted_by'] as int? ?? 0,
    );
  }
}
