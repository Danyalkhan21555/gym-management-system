import 'package:flutter/foundation.dart';

import '../model/member_model.dart';
import '../repository/member_repository.dart';

class MemberViewModel extends ChangeNotifier {
  final MemberRepository _repository;

  List<MemberModel> _allMembers = [];
  List<MemberModel> _filteredMembers = [];
  MemberModel? _currentMember;

  bool _isLoading = false;
  bool _isLoadingMember = false;
  bool _isCreating = false;
  bool _isDeleting = false;
  String? _errorMessage;
  String? _memberError;
  String? _createError;
  String _searchQuery = '';

  MemberViewModel(this._repository);

  // ── Getters ──────────────────────────────────────────────────────────────

  List<MemberModel> get members => _filteredMembers;
  List<MemberModel> get allMembers => _allMembers;
  MemberModel? get currentMember => _currentMember;
  bool get isLoading => _isLoading;
  bool get isLoadingMember => _isLoadingMember;
  bool get isCreating => _isCreating;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;
  String? get memberError => _memberError;
  String? get createError => _createError;
  String get searchQuery => _searchQuery;

  bool get isEmpty => !_isLoading && _filteredMembers.isEmpty;

  // ── Read: List ───────────────────────────────────────────────────────────

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

  void searchMembers(String query) {
    _searchQuery = query.trim();
    _applySearch();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Read: Single Member (for Member Dashboard) ───────────────────────────

  /// Loads a single member by UID and stores in [_currentMember].
  Future<void> loadMember(String uid) async {
    _isLoadingMember = true;
    _memberError = null;
    notifyListeners();

    try {
      _currentMember = await _repository.getMemberById(uid);
      if (_currentMember == null) {
        _memberError = 'Member profile not found.';
      }
    } catch (e) {
      _memberError = 'Failed to load member.';
    } finally {
      _isLoadingMember = false;
      notifyListeners();
    }
  }

  /// Clears the current member (e.g., on logout).
  void clearCurrentMember() {
    _currentMember = null;
    _memberError = null;
    notifyListeners();
  }

  // ── Create ──────────────────────────────────────────────────────────────

  Future<MemberModel?> createMember({
    required String name,
    required String phone,
    required String email,
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

  void clearCreateError() {
    _createError = null;
    notifyListeners();
  }

  // ── Delete ──────────────────────────────────────────────────────────────

  Future<bool> deleteMember(String uid) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.deleteMember(uid);
      if (success) {
        await loadMembers();
      } else {
        _errorMessage = 'Failed to remove member.';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

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