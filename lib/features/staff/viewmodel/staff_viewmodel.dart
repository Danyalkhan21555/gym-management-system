import 'package:flutter/foundation.dart';
import '../model/staff_model.dart';
import '../repository/staff_repository.dart';

class StaffViewModel extends ChangeNotifier {
  final StaffRepository _repository;

  /// Full list fetched from Firestore (source of truth for search).
  List<StaffModel> _allStaff = [];

  /// Visible list after applying the current search query.
  List<StaffModel> _filteredStaff = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  bool _isCreating = false;
  String? _createError;

  StaffViewModel(this._repository);

  // ── Getters ─────────────────────────────────────────────────────────────────

  /// The filtered (visible) list of staff — use this in the UI.
  List<StaffModel> get staff => _filteredStaff;

  /// The unfiltered list — useful for counts or export.
  List<StaffModel> get allStaff => _allStaff;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  bool get isCreating => _isCreating;
  String? get createError => _createError;

  /// True when not loading and the visible list is empty.
  bool get isEmpty => !_isLoading && _filteredStaff.isEmpty;

  // ── Methods ──────────────────────────────────────────────────────────────────

  /// Fetches all staff from the repository and applies the current search query.
  Future<void> loadStaff() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allStaff = await _repository.getAllStaff();
      _applySearch();
    } catch (e) {
      _errorMessage = 'Failed to load staff.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the search query and filters the visible list immediately.
  void searchStaff(String query) {
    _searchQuery = query.trim();
    _applySearch();
    notifyListeners();
  }

  /// Clears any currently displayed error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Creates a new staff member via the repository.
  /// Returns the [StaffModel] on success, or null on failure.
  Future<StaffModel?> createStaff({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      final staff = await _repository.createStaff(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );
      if (staff == null) {
        _createError = 'Failed to create staff. Email may already be in use.';
      } else {
        // Refresh the list so the new staff appears immediately.
        await loadStaff();
      }
      return staff;
    } catch (e) {
      _createError = 'Something went wrong. Please try again.';
      return null;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Clears the create-staff error message.
  void clearCreateError() {
    _createError = null;
    notifyListeners();
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  /// Filters [_allStaff] by [_searchQuery] and stores the result in
  /// [_filteredStaff]. Matches against name, profileId, and role.
  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredStaff = List.from(_allStaff);
      return;
    }

    final query = _searchQuery.toLowerCase();
    _filteredStaff = _allStaff.where((member) {
      return member.name.toLowerCase().contains(query) ||
          member.profileId.toLowerCase().contains(query) ||
          member.role.toLowerCase().contains(query);
    }).toList();
  }
}
