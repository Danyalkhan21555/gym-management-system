import 'package:flutter/foundation.dart';

import '../model/diet_plan_model.dart';
import '../repository/diet_plan_repository.dart';

class DietPlanViewModel extends ChangeNotifier {
  final DietPlanRepository _repository;

  DietPlanModel? _currentPlan;
  List<DietPlanModel> _trainerPlans = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  DietPlanViewModel(this._repository);

  // ── Getters ──────────────────────────────────────────────────────────────

  DietPlanModel? get currentPlan => _currentPlan;
  List<DietPlanModel> get trainerPlans => _trainerPlans;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get hasPlan => _currentPlan != null;

  // ── Load a single member's plan ──────────────────────────────────────────

  /// Loads the diet plan for a specific member.
  /// If no plan exists, currentPlan will be null.
  Future<void> loadPlan(String memberId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPlan = await _repository.getDietPlan(memberId);
    } catch (e) {
      _errorMessage = 'Failed to load diet plan.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Save (create or update) ──────────────────────────────────────────────

  /// Saves a diet plan. Creates a new one if none exists for the member,
  /// otherwise updates the existing plan's content.
  ///
  /// Returns true on success.
  Future<bool> savePlan({
    required String memberId,
    required String memberName,
    required String trainerId,
    required String trainerName,
    required String content,
  }) async {
    // Validate content
    if (content.trim().isEmpty) {
      _errorMessage = 'Diet plan cannot be empty.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();

      // Build the plan model — new or updated
      final plan = _currentPlan != null
          ? _currentPlan!.copyWith(content: content.trim(), updatedAt: now)
          : DietPlanModel(
              memberId: memberId,
              memberName: memberName,
              trainerId: trainerId,
              trainerName: trainerName,
              content: content.trim(),
              createdAt: now,
              updatedAt: now,
            );

      final success = await _repository.saveDietPlan(plan);

      if (success) {
        _currentPlan = plan;
      } else {
        _errorMessage = 'Failed to save diet plan.';
      }

      return success;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ── Load trainer's plans (for stats) ─────────────────────────────────────

  /// Loads all plans written by a specific trainer.
  /// Used for "X plans written" stats on the trainer home tab.
  Future<void> loadPlansByTrainer(String trainerId) async {
    try {
      _trainerPlans = await _repository.getPlansByTrainer(trainerId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading trainer plans: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Clears the currently loaded plan (e.g., when switching members).
  void clearPlan() {
    _currentPlan = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears any error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
