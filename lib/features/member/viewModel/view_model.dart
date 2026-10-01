import 'package:flutter/foundation.dart';

import '../model/member_model.dart';
import '../repository/member_repository.dart';

class MemberViewModel extends ChangeNotifier {
  final MemberRepository _repository;

  List<MemberModel> _allMembers = [];
  List<MemberModel> _filteredMembers = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;
  String? _createError;
  String _searchQuery = '';

  MemberViewModel(this._repository);

  // ── Getters ──────────────────────────────────────────────────────────────

  List<MemberModel> get members => _filteredMembers;
  List<MemberModel> get allMembers => _allMembers;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;
  String? get createError => _createError;
  String get searchQuery => _searchQuery;

  /// True when not loading and the visible list is empty.
  bool get isEmpty => !_isLoading && _filteredMembers.isEmpty;

  // ── Read methods ─────────────────────────────────────────────────────────

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

  /// Clears any currently displayed error message (list load error).
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Create member ────────────────────────────────────────────────────────

  /// Creates a new member:
  ///   - Uses the receptionist-supplied [email] directly (no auto-generation)
  ///   - Creates a Firebase Auth account (without logging out the current user)
  ///   - Writes the member doc to Firestore
  ///   - Refreshes the member list
  ///
  /// Returns the created [MemberModel] on success, null on failure.
  Future<MemberModel?> createMember({
    required String name,
    required String phone,
    required String email, // email entered manually by the receptionist
    required String password,
    required String address,
    required String gender,
    required String plan,
    required int duration,
  }) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      // Pass the receptionist-supplied email directly to the repository
      final member = await _repository.createMember(
        name: name,
        phone: phone,
        email: email,
        password: password,
        address: address,
        gender: gender,
        plan: plan,
        duration: duration,
      );

      if (member == null) {
        _createError =
            'Failed to create member. Email may already be in use, or invalid data.';
        return null;
      }

      // Refresh the list so the new member appears immediately
      await loadMembers();
      return member;
    } catch (e) {
      _createError = 'Something went wrong. Please try again.';
      return null;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Clears the create-member error message.
  void clearCreateError() {
    _createError = null;
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
