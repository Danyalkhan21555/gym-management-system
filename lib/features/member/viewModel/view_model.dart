import 'package:flutter/foundation.dart';

import '../model/member_model.dart';
import '../repository/member_repository.dart';

class MemberViewModel extends ChangeNotifier {
  final MemberRepository _repository;

  List<MemberModel> _allMembers = [];
  List<MemberModel> _filteredMembers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  MemberViewModel(this._repository);

  // ── Getters ──────────────────────────────────────────────────────────────

  List<MemberModel> get members => _filteredMembers;
  List<MemberModel> get allMembers => _allMembers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  /// True when not loading and the visible list is empty.
  bool get isEmpty => !_isLoading && _filteredMembers.isEmpty;

  // ── Methods ──────────────────────────────────────────────────────────────

  /// Fetches all members from the repository and applies the current
  /// search query.
  Future<void> loadMembers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allMembers = await _repository.getAllMembers();
      _applySearch();
    } catch (e) {
      _errorMessage = 'Failed to load members.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the search query and filters the visible list immediately.
  void searchMembers(String query) {
    _searchQuery = query.trim();
    _applySearch();
    notifyListeners();
  }

  /// Clears any currently displayed error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Filters [_allMembers] by [_searchQuery] and stores the result in
  /// [_filteredMembers]. Matches against name, memberId, and phone.
  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredMembers = List.from(_allMembers);
      return;
    }

    final query = _searchQuery.toLowerCase();
    _filteredMembers = _allMembers.where((member) {
      return member.name.toLowerCase().contains(query) ||
          member.memberId.toLowerCase().contains(query) ||
          member.phone.toLowerCase().contains(query);
    }).toList();
  }
}
