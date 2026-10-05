import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../model/diet_plan_model.dart';

class DietPlanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'diet_plans';

  /// Fetches the diet plan for a specific member.
  /// Returns null if no plan exists or on error.
  Future<DietPlanModel?> getDietPlan(String memberId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .doc(memberId)
          .get();

      if (!snapshot.exists) {
        return null;
      }

      return DietPlanModel.fromFirestore(snapshot.data()!);
    } catch (e) {
      debugPrint('Error getting diet plan for $memberId: $e');
      return null;
    }
  }

  /// Saves (creates or updates) a diet plan.
  /// Doc ID = memberId so there is exactly one plan per member.
  /// Returns true on success.
  Future<bool> saveDietPlan(DietPlanModel plan) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(plan.memberId)
          .set(plan.toFirestore());
      return true;
    } catch (e) {
      debugPrint('Error saving diet plan: $e');
      return false;
    }
  }

  /// Fetches all diet plans written by a specific trainer.
  /// Useful for showing "X plans written" stats.
  /// Returns an empty list on error.
  Future<List<DietPlanModel>> getPlansByTrainer(String trainerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('trainerId', isEqualTo: trainerId)
          .get();

      return snapshot.docs
          .map((doc) => DietPlanModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting trainer plans: $e');
      return [];
    }
  }

  /// Fetches all diet plans (used for global stats).
  /// Returns an empty list on error.
  Future<List<DietPlanModel>> getAllPlans() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => DietPlanModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting all diet plans: $e');
      return [];
    }
  }
}
