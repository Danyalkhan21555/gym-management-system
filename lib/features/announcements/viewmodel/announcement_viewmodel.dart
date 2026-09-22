import 'package:flutter/foundation.dart';
import '../model/announcement_model.dart';
import '../repository/announcement_repository.dart';

class AnnouncementViewModel extends ChangeNotifier {
  final AnnouncementRepository _repository;
  AnnouncementModel? _announcement;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  AnnouncementViewModel(this._repository);

  // Getters
  AnnouncementModel? get announcement => _announcement;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get hasAnnouncement => _announcement != null;

  /// Loads the current announcement from the repository.
  Future<void> loadAnnouncement() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _announcement = await _repository.getAnnouncement();
    } catch (e) {
      _errorMessage = 'Failed to load announcement.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves an announcement through the repository and updates local state.
  /// Returns true if successful, false otherwise.
  Future<bool> saveAnnouncement({
    required String content,
    required String adminUid,
    required String adminName,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final model = AnnouncementModel(
        content: content.trim(),
        updatedAt: DateTime.now(),
        updatedBy: adminUid,
        updatedByName: adminName,
      );
      await _repository.saveAnnouncement(model);
      _announcement = model;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save announcement.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Deletes the current announcement through the repository.
  /// Returns true if successful, false otherwise.
  Future<bool> deleteAnnouncement() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteAnnouncement();
      _announcement = null;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete announcement.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Clears any currently displayed error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
