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
  bool _isUpdatingMember = false;
  String? _errorMessage;
  String? _memberError;
  String? _createError;
  String? _updateMemberError;
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
  bool get isUpdatingMember => _isUpdatingMember;
  String? get errorMessage => _errorMessage;
  String? get memberError => _memberError;
  String? get createError => _createError;
  String? get updateMemberError => _updateMemberError;
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

  // ── Read: Single Member ──────────────────────────────────────────────────

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

  // ── Update (member self-edit) ────────────────────────────────────────────

  /// Updates a member's editable fields.
  /// [uid] is the Firestore doc ID of the member to update.
  /// Also refreshes [_currentMember] if it matches [uid].
  Future<bool> updateMember({
    required String uid,
    required String name,
    required String phone,
    required String address,
    required String gender,
  }) async {
    _isUpdatingMember = true;
    _updateMemberError = null;
    notifyListeners();

    try {
      final success = await _repository.updateMember(
        uid: uid,
        name: name,
        phone: phone,
        address: address,
        gender: gender,
      );

      if (success) {
        // Refresh current member locally if this was the current member
        if (_currentMember != null && _currentMember!.uid == uid) {
          _currentMember = _currentMember!.copyWith(
            name: name,
            phone: phone,
            address: address,
            gender: gender,
          );
        }
      } else {
        _updateMemberError = 'Failed to update profile.';
      }
      return success;
    } catch (e) {
      _updateMemberError = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isUpdatingMember = false;
      notifyListeners();
    }
  }

  void clearUpdateMemberError() {
    _updateMemberError = null;
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