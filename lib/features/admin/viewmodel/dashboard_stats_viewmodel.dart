import 'package:flutter/foundation.dart';

import '../model/dashboard_stats_model.dart';
import '../repository/dashboard_stats_repository.dart';

class DashboardStatsViewModel extends ChangeNotifier {
  final DashboardStatsRepository _repository;

  DashboardStatsModel _stats = DashboardStatsModel.empty();
  bool _isLoading = false;
  String? _errorMessage;

  DashboardStatsViewModel(this._repository);

  // ── Getters ─────────────────────────────────────────────────────────────────

  DashboardStatsModel get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Methods ──────────────────────────────────────────────────────────────────

  /// Loads dashboard stats from the repository and notifies listening widgets.
  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await _repository.getStats();
    } catch (e) {
      _errorMessage = 'Failed to load stats.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
