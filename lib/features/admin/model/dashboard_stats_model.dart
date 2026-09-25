class DashboardStatsModel {
  /// Total count of all registered members.
  final int totalMembers;

  /// Count of members with status 'active'.
  final int activeMembers;

  /// Total count of all staff members.
  final int totalStaff;

  /// Count of members registered during the current calendar month.
  final int newMembersThisMonth;

  const DashboardStatsModel({
    required this.totalMembers,
    required this.activeMembers,
    required this.totalStaff,
    required this.newMembersThisMonth,
  });

  /// Factory for initial/empty statistics state before data loads.
  factory DashboardStatsModel.empty() => const DashboardStatsModel(
        totalMembers: 0,
        activeMembers: 0,
        totalStaff: 0,
        newMembersThisMonth: 0,
      );
}
